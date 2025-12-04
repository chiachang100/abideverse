// lib/features/scriptures/data/scripture_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/scripture.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

class ScriptureRepository {
  final String locale;

  ScriptureRepository({this.locale = 'zh-TW'});

  /// Load the JSON file based on locale
  Future<List<Scripture>> getScriptures() async {
    final String path = _getJsonPath(locale);
    final String data = await rootBundle.loadString(path);
    final List<dynamic> jsonResult = json.decode(data);

    List<Scripture> scriptures = jsonResult
        .map((json) => Scripture.fromJson(json))
        .toList();

    // Sort by articleId descending
    scriptures.sort((a, b) => b.articleId.compareTo(a.articleId));

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
      case 'en-US':
        return 'assets/scriptures/scriptures_en-US.json';
      case 'zh-CN':
        return 'assets/scriptures/scriptures_zh-CN.json';
      case 'zh-TW':
      default:
        return 'assets/scriptures/scriptures_zh-TW.json';
    }
  }
}
