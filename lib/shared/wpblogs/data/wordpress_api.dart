import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abideverse/shared/wpblogs/models/wpblog.dart';

class WordpressApi {
  static const String baseUrl = 'https://joyolord.com/wp-json/wp/v2';

  Future<List<WPPost>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((json) => WPPost.fromJson(json)).toList();
    }

    throw Exception('[WordpressApi.getPosts]: Failed to load posts');
  }
}
