import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart'; // for firstWhereOrNull
import 'package:abideverse/shared/models/sort_order.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class ScriptureRepository {
  final String locale;

  ScriptureRepository({this.locale = LocaleConstants.defaultLocale});

  /// Load the JSON file based on locale
  Future<List<Scripture>> getScriptures({
    SortOrder order = SortOrder.asc,
  }) async {
    final String path = _getJsonPath(locale);
    final String data = await rootBundle.loadString(path);
    final List<dynamic> jsonResult = json.decode(data);

    List<Scripture> scriptures = jsonResult
        .map((json) => Scripture.fromJson(json))
        .toList();

    // Apply sorting based on order
    if (order == SortOrder.asc) {
      scriptures.sort((a, b) => a.articleId.compareTo(b.articleId));
    } else {
      scriptures.sort((a, b) => b.articleId.compareTo(a.articleId));
    }

    return scriptures;
  }

  /// Get a single scripture by articleId
  Future<Scripture?> getScripture(int articleId) async {
    final scriptures = await getScriptures();
    return scriptures.firstWhereOrNull((s) => s.articleId == articleId);
  }

  /// Map locale to JSON asset path
  String _getJsonPath(String locale) {
    switch (locale) {
      case LocaleConstants.enUS:
        return 'assets/scriptures/scriptures_en_US.json';
      case LocaleConstants.zhCN:
        return 'assets/scriptures/scriptures_zh_CN.json';
      case LocaleConstants.zhTW:
      default:
        return 'assets/scriptures/scriptures_zh_TW.json';
    }
  }
}
