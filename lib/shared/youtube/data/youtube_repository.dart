import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeRepository {
  final YoutubeExplode _yt;

  YoutubeRepository(this._yt);

  Future<List<Video>> fetchPlaylist(String playlistId) async {
    try {
      // Returns a Stream of videos, converted to a List
      return await _yt.playlists.getVideos(playlistId).toList();
    } catch (e) {
      throw Exception('YoutubeRepository Error: $e');
    }
  }
}
