import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;

import 'package:abideverse/shared/youtube/data/youtube_repository.dart';
import 'package:abideverse/shared/youtube/data/app_video.dart';

// The "Service" setup
final youtubeClientProvider = Provider.autoDispose<YoutubeExplode>((ref) {
  final client = YoutubeExplode();
  ref.onDispose(() => client.close());
  return client;
});

final youtubeRepositoryProvider = Provider<IYoutubeRepository>((ref) {
  // 1. Logic for choosing the engine
  if (kIsWeb) {
    const apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

    debugPrint("[youtube_repository] Web: Found YouTube API Key.");

    // Fallback: If no key is provided, the UI will handle the error by launching a link
    if (apiKey.isEmpty) {
      debugPrint("[youtube_repository] Web: YouTube API Key not found.");
      return MissingKeyRepository();
    }

    return GoogleApiYoutubeRepository(apiKey);
  } else {
    // 2. Logic for iOS/Android

    debugPrint("[youtube_repository] iOS/Android: Use YoutubeExplode.");

    final yt = YoutubeExplode();
    ref.onDispose(() => yt.close());
    return ExplodeYoutubeRepository(yt);
  }
});

// A "Dummy" repository that throws a specific error if the key is missing
class MissingKeyRepository implements IYoutubeRepository {
  @override
  Future<List<AppVideo>> fetchPlaylist(String id) =>
      throw Exception('MISSING_KEY');
  @override
  Future<(List<AppVideo>, String?)> fetchPlaylistBatch(
    String id, {
    int limit = 20,
    String? pageToken,
  }) => throw Exception('MISSING_KEY');
}

// The reactive state that your UI will consume
final youtubePlaylistService = FutureProvider.family<List<AppVideo>, String>((
  ref,
  id,
) async {
  try {
    final repo = ref.watch(youtubeRepositoryProvider);
    final videos = await repo.fetchPlaylist(id);
    debugPrint('Successfully fetched ${videos.length} videos for $id');
    return videos;
  } catch (e, stack) {
    debugPrint('YOUTUBE ERROR: $e');
    debugPrint('STACKTRACE: $stack');
    rethrow;
  }
});
