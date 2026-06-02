import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:abideverse/shared/wpblogs/models/wpblog.dart';

class WordpressApi {
  static const String baseUrl = 'https://joyolord.com/wp-json/wp/v2';

  Future<List<WPPost>> getPosts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/posts?per_page=10'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => WPPost.fromJson(json)).toList();
    } on TimeoutException {
      throw Exception('[WordpressApi.getPosts] Request timed out');
    } on FormatException {
      throw Exception('[WordpressApi.getPosts] Invalid JSON');
    } catch (e) {
      throw Exception('[WordpressApi.getPosts] $e');
    }
  }
}
