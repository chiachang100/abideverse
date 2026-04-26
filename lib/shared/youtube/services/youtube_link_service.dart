import 'package:abideverse/shared/services/url_service.dart';

class YoutubeLinkService {
  /// Specialized logic for YouTube Playlists
  static Future<void> launchPlaylist(String playlistId) async {
    final url = 'https://www.youtube.com/playlist?list=$playlistId';
    await UrlService.launch(url);
  }

  /// Specialized logic for YouTube Videos
  static Future<void> launchVideo(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    await UrlService.launch(url);
  }
}
