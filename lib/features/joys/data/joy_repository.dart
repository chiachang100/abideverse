import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart'; // for firstWhereOrNull
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

final logJoyRepository = Logger('joy_repository');

class JoyRepository {
  final String locale;

  JoyRepository({this.locale = LocaleConstants.defaultLocale});

  // In-memory cache - shared per repository instance (can be made static if desired)
  static List<Joy>? _cachedJoys;

  /// Public loader - returns cached list if loaded; parses using compute() once.
  Future<List<Joy>> getJoys({
    SortOrder order = SortOrder.asc,
    bool forceReload = false,
    bool shuffle = false,
  }) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'joy_repository',
      parameters: {
        'joy_repository': 'getJoys',
        'joy_repository_class': 'JoyRepository',
      },
    );

    final String path = _getJsonPath(locale);

    logJoyRepository.info(
      '[JoyRepository] getJoys: locale=$locale; forceReload=$forceReload; AppConfig.forceReloadRepo=${AppConfig.forceReloadRepo}; order=$order; path=$path.',
    );

    if (_cachedJoys == null || forceReload || AppConfig.forceReloadRepo) {
      logJoyRepository.info(
        '[JoyRepository] getJoys: reload joy repository: locale=$locale; forceReload=$forceReload; AppConfig.forceReloadRepo=${AppConfig.forceReloadRepo}; order=$order; path=$path.',
      );

      final jsonString = await rootBundle.loadString(path);
      // parse on background isolate
      final parsed = await compute(_parseJoys, jsonString);
      _cachedJoys = parsed;

      // Turn off Global forceReloadRepo flag
      AppConfig.forceReloadRepo = false;

      logJoyRepository.info(
        '[JoyRepository] Turn off forceReloadRepo: AppConfig.forceReloadRepo=${AppConfig.forceReloadRepo}; order=$order; path=$path.',
      );
    }

    // Handle the return logic with the new shuffle parameter
    if (shuffle) {
      // Create a copy so we don't permanently mess up the order of the cached list
      final List<Joy> randomList = List<Joy>.from(_cachedJoys!);
      randomList.shuffle();
      return randomList;
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
