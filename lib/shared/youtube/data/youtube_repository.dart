import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:http/http.dart' as http;

import 'package:abideverse/shared/youtube/data/app_video.dart';

// 1. Add the part file (ensure it matches the filename)
//part 'youtube_repository.g.dart';

class ApiKeyClient extends http.BaseClient {
  final String apiKey;
  final http.Client _inner = http.Client();

  ApiKeyClient(this.apiKey);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Manually append the key to the URL query parameters
    final uri = request.url.replace(
      queryParameters: {...request.url.queryParameters, 'key': apiKey},
    );

    // Create a new request with the updated URI
    final newRequest = http.Request(request.method, uri)
      ..headers.addAll(request.headers)
      ..bodyBytes = (request is http.Request) ? request.bodyBytes : [];

    return _inner.send(newRequest);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

abstract class IYoutubeRepository {
  // For fetching a simple list (usually the first page)
  Future<List<AppVideo>> fetchPlaylist(String playlistId);

  // For the pagination service
  Future<(List<AppVideo>, String?)> fetchPlaylistBatch(
    String playlistId, {
    int limit = 20,
    String? pageToken,
  });
}

// youtube_repository.dart
class GoogleApiYoutubeRepository implements IYoutubeRepository {
  final youtube.YouTubeApi _api;

  // Initialize with our special client
  GoogleApiYoutubeRepository(String apiKey)
    : _api = youtube.YouTubeApi(ApiKeyClient(apiKey));

  @override
  Future<List<AppVideo>> fetchPlaylist(String playlistId) async {
    final (items, _) = await fetchPlaylistBatch(playlistId);
    return items;
  }

  @override
  Future<(List<AppVideo>, String?)> fetchPlaylistBatch(
    String playlistId, {
    int limit = 20,
    String? pageToken,
  }) async {
    try {
      final response = await _api.playlistItems.list(
        ['snippet', 'contentDetails'],
        playlistId: playlistId,
        maxResults: limit,
        pageToken: pageToken,
      );

      final items = (response.items ?? [])
          .map(
            (item) => AppVideo(
              id: item.contentDetails?.videoId ?? '',
              title: item.snippet?.title ?? 'No Title',
              author:
                  item.snippet?.videoOwnerChannelTitle ??
                  item.snippet?.channelTitle ??
                  'Unknown Author',
              thumbnails: AppThumbnails(
                lowResUrl: item.snippet?.thumbnails?.default_?.url ?? '',
                mediumResUrl: item.snippet?.thumbnails?.medium?.url ?? '',
                highResUrl: item.snippet?.thumbnails?.high?.url ?? '',
              ),
              description: item.snippet?.description,
            ),
          )
          .toList();

      return (items, response.nextPageToken);
    } catch (e) {
      throw Exception('GoogleApiYoutubeRepository Error: $e');
    }
  }
}

class ExplodeYoutubeRepository implements IYoutubeRepository {
  final YoutubeExplode _yt;

  ExplodeYoutubeRepository(this._yt);

  @override
  Future<List<AppVideo>> fetchPlaylist(String playlistId) async {
    final (items, _) = await fetchPlaylistBatch(playlistId);
    return items;
  }

  @override
  Future<(List<AppVideo>, String?)> fetchPlaylistBatch(
    String playlistId, {
    int limit = 20,
    String? pageToken,
  }) async {
    try {
      // Convert pageToken (string) back to skip (int)
      final skip = int.tryParse(pageToken ?? '0') ?? 0;

      final videoStream = _yt.playlists.getVideos(playlistId);
      final videos = await videoStream.skip(skip).take(limit).toList();

      // The "next token" is just the next skip index
      final nextToken = (videos.length == limit)
          ? (skip + limit).toString()
          : null;

      // Mapping Explode Video to Google PlaylistItem snippet
      final mappedItems = videos
          .map(
            (v) => AppVideo(
              id: v.id.value,
              title: v.title,
              author: v.author,
              thumbnails: AppThumbnails(
                lowResUrl: v.thumbnails.lowResUrl,
                mediumResUrl: v.thumbnails.mediumResUrl,
                highResUrl: v.thumbnails.highResUrl,
              ),
              description: v.description,
            ),
          )
          .toList();

      return (mappedItems, nextToken);
    } catch (e) {
      throw Exception('ExplodeYoutubeRepository Error: $e');
    }
  }
}

// class YoutubeRepository {
//   final YoutubeExplode _yt;

//   YoutubeRepository(this._yt);

//   Future<List<Video>> fetchPlaylist(String playlistId) async {
//     try {
//       // Returns a Stream of videos, converted to a List
//       return await _yt.playlists.getVideos(playlistId).toList();
//     } catch (e) {
//       throw Exception('YoutubeRepository Error: $e');
//     }
//   }

//   Future<List<Video>> fetchPlaylistBatch(
//     String playlistId, {
//     int limit = 20,
//     int skip = 0,
//   }) async {
//     try {
//       // getVideos returns a Stream, which is perfect for batching
//       final videoStream = _yt.playlists.getVideos(playlistId);

//       // Skip the ones we already have and take the next batch
//       return await videoStream.skip(skip).take(limit).toList();
//     } catch (e) {
//       throw Exception('YoutubeRepository Error: $e');
//     }
//   }
// }

// // 2. Add the provider function here
// @riverpod
// YoutubeRepository youtubeRepository(Ref ref) {
//   final yt = YoutubeExplode();
//   ref.onDispose(() => yt.close());
//   return YoutubeRepository(yt);
// }
