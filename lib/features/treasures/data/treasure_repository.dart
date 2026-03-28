// lib/features/treasures/data/treasure_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart'; // for firstWhereOrNull
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/features/treasures/models/treasure.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class TreasureRepository {
  final String locale;

  TreasureRepository({this.locale = LocaleConstants.defaultLocale});

  // In-memory cache - shared per repository instance (can be made static if desired)
  static List<Treasure>? _cachedTreasures;

  static const String _masterJsonPath =
      'assets/treasures/treasures_master.json';

  /// Public loader - returns cached list if loaded; parses using compute() once.
  Future<List<Treasure>> getTreasures({
    SortOrder order = SortOrder.none,
    bool forceReload = false,
    bool shuffle = false,
  }) async {
    if (_cachedTreasures == null || forceReload) {
      final jsonString = await rootBundle.loadString(_masterJsonPath);
      // parse on background isolate
      final parsed = await compute(_parseTreasures, jsonString);
      _cachedTreasures = parsed;
    }

    // Handle the return logic with the new shuffle parameter
    if (shuffle) {
      // Create a copy so we don't permanently mess up the order of the cached list
      final List<Treasure> randomList = List<Treasure>.from(_cachedTreasures!);
      randomList.shuffle();
      return randomList;
    }

    // return a sorted copy if requested order differs
    switch (order) {
      case SortOrder.asc:
        // cached list is kept as-is (assume asc by articleId). Ensure it's sorted.
        _cachedTreasures!.sort((a, b) => a.articleId.compareTo(b.articleId));
        return _cachedTreasures!;
      case SortOrder.desc:
        final List<Treasure> clone = List<Treasure>.from(_cachedTreasures!);
        clone.sort((a, b) => b.articleId.compareTo(a.articleId));
        return clone;
      default:
        return _cachedTreasures!;
    }
  }

  /// Get a single treasure by articleId using cached list (loads first if needed)
  Future<Treasure?> getTreasure(int articleId) async {
    final list = await getTreasures();
    return list.firstWhereOrNull((s) => s.articleId == articleId);
  }

  /// Simple search that uses cached list
  Future<List<Treasure>> search(
    String query, {
    SortOrder order = SortOrder.asc,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return getTreasures(order: order);
    }
    final list = await getTreasures(order: order);
    return list.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.treasureMeaning.toLowerCase().contains(q) ||
          s.treasureStory.toLowerCase().contains(q) ||
          s.treasureRealLife.toLowerCase().contains(q);
    }).toList();
  }
}

/// Top-level parser function run in an isolate via compute()
List<Treasure> _parseTreasures(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList
      .map((j) => Treasure.fromJson(j as Map<String, dynamic>))
      .toList();
}
