// lib/features/scriptures/data/scripture_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart'; // for firstWhereOrNull
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class ScriptureRepository {
  final String locale;

  ScriptureRepository({this.locale = LocaleConstants.defaultLocale});

  // In-memory cache - shared per repository instance (can be made static if desired)
  static List<Scripture>? _cachedScriptures;

  static const String _masterJsonPath =
      'assets/scriptures/scriptures_master.json';

  /// Public loader - returns cached list if loaded; parses using compute() once.
  Future<List<Scripture>> getScriptures({
    SortOrder order = SortOrder.asc,
    bool forceReload = false,
    bool shuffle = false,
  }) async {
    if (_cachedScriptures == null || forceReload) {
      final jsonString = await rootBundle.loadString(_masterJsonPath);
      // parse on background isolate
      final parsed = await compute(_parseScriptures, jsonString);
      _cachedScriptures = parsed;
    }

    // Handle the return logic with the new shuffle parameter
    if (shuffle) {
      // Create a copy so we don't permanently mess up the order of the cached list
      final List<Scripture> randomList = List<Scripture>.from(
        _cachedScriptures!,
      );
      randomList.shuffle();
      return randomList;
    }

    // return a sorted copy if requested order differs
    if (order == SortOrder.asc) {
      // cached list is kept as-is (assume asc by articleId). Ensure it's sorted.
      _cachedScriptures!.sort((a, b) => a.articleId.compareTo(b.articleId));
      return _cachedScriptures!;
    } else {
      final List<Scripture> clone = List<Scripture>.from(_cachedScriptures!);
      clone.sort((a, b) => b.articleId.compareTo(a.articleId));
      return clone;
    }
  }

  /// Get a single scripture by articleId using cached list (loads first if needed)
  Future<Scripture?> getScripture(int articleId) async {
    final list = await getScriptures();
    return list.firstWhereOrNull((s) => s.articleId == articleId);
  }

  /// Simple search that uses cached list
  Future<List<Scripture>> search(
    String query, {
    SortOrder order = SortOrder.asc,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return getScriptures(order: order);
    }
    final list = await getScriptures(order: order);
    return list.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.scriptureName.toLowerCase().contains(q) ||
          s.scriptureVerse.toLowerCase().contains(q);
    }).toList();
  }
}

/// Top-level parser function run in an isolate via compute()
List<Scripture> _parseScriptures(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList
      .map((j) => Scripture.fromJson(j as Map<String, dynamic>))
      .toList();
}
