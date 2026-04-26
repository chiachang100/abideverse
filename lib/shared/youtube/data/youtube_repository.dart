import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// 1. Add the part file (ensure it matches the filename)
part 'youtube_repository.g.dart';

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

  Future<List<Video>> fetchPlaylistBatch(
    String playlistId, {
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      // getVideos returns a Stream, which is perfect for batching
      final videoStream = _yt.playlists.getVideos(playlistId);

      // Skip the ones we already have and take the next batch
      return await videoStream.skip(skip).take(limit).toList();
    } catch (e) {
      throw Exception('YoutubeRepository Error: $e');
    }
  }
}

// 2. Add the provider function here
@riverpod
YoutubeRepository youtubeRepository(Ref ref) {
  final yt = YoutubeExplode();
  ref.onDispose(() => yt.close());
  return YoutubeRepository(yt);
}
