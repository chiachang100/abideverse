import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart'; // for firstWhereOrNull
import 'package:abideverse/shared/models/sort_order.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class JoyRepository {
  final String locale;

  JoyRepository({this.locale = LocaleConstants.zhTW});

  /// Load Joy JSON based on locale
  Future<List<Joy>> getJoys({SortOrder order = SortOrder.asc}) async {
    final String path = _getJsonPath(locale);
    final String data = await rootBundle.loadString(path);
    final List<dynamic> jsonResult = json.decode(data);

    // Convert to Joy objects
    List<Joy> joys = jsonResult.map((json) => Joy.fromJson(json)).toList();

    // Apply sorting
    if (order == SortOrder.asc) {
      joys.sort((a, b) => a.articleId.compareTo(b.articleId));
    } else {
      joys.sort((a, b) => b.articleId.compareTo(a.articleId));
    }

    return joys;
  }

  /// Get single joy by articleId
  Future<Joy?> getJoy(int articleId) async {
    final joys = await getJoys();
    return joys.firstWhereOrNull((j) => j.articleId == articleId);
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
