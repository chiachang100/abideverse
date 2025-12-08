import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart'; // for firstWhereOrNull
import 'package:abideverse/shared/models/sort_order.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class JoyRepository {
  final String locale;

  JoyRepository({this.locale = LocaleConstants.defaultLocale});

  // In-memory cache - shared per repository instance (can be made static if desired)
  static List<Joy>? _cachedJoys;

  /// Public loader - returns cached list if loaded; parses using compute() once.
  Future<List<Joy>> getJoys({
    SortOrder order = SortOrder.asc,
    bool forceReload = false,
  }) async {
    final String path = _getJsonPath(locale);
    if (_cachedJoys == null || forceReload) {
      final jsonString = await rootBundle.loadString(path);
      // parse on background isolate
      final parsed = await compute(_parseJoys, jsonString);
      _cachedJoys = parsed;
    }

    // return a sorted copy if requested order differs
    if (order == SortOrder.asc) {
      // cached list is kept as-is (assume asc by articleId). Ensure it's sorted.
      _cachedJoys!.sort((a, b) => a.articleId.compareTo(b.articleId));
      return _cachedJoys!;
    } else {
      final List<Joy> clone = List<Joy>.from(_cachedJoys!);
      clone.sort((a, b) => b.articleId.compareTo(a.articleId));
      return clone;
    }
  }

  /// Get a single scripture by articleId using cached list (loads first if needed)
  Future<Joy?> getJoy(int articleId) async {
    final list = await getJoys();
    return list.firstWhereOrNull((j) => j.articleId == articleId);
  }

  /// Simple search that uses cached list
  Future<List<Joy>> search(
    String query, {
    SortOrder order = SortOrder.asc,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return getJoys(order: order);
    }
    final list = await getJoys(order: order);
    return list.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.scriptureName.toLowerCase().contains(q) ||
          s.scriptureVerse.toLowerCase().contains(q);
    }).toList();
  }

  /// Locale → JSON asset mapping
  String _getJsonPath(String locale) {
    switch (locale) {
      case LocaleConstants.enUS:
        return 'assets/joys/joys_en-US.json';
      case LocaleConstants.zhCN:
        return 'assets/joys/joys_zh-CN.json';
      case LocaleConstants.zhTW:
      default:
        return 'assets/joys/joys_zh-TW.json';
    }
  }
}

/// Top-level parser function run in an isolate via compute()
List<Joy> _parseJoys(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList.map((j) => Joy.fromJson(j as Map<String, dynamic>)).toList();
}
