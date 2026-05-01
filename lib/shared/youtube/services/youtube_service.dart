import 'dart:async';

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
  const apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  // Create the reliable API repo (but don't use it as primary on mobile yet)
  final IYoutubeRepository googleRepo = apiKey.isNotEmpty
      ? GoogleApiYoutubeRepository(apiKey)
      : MissingKeyRepository();

  if (kIsWeb) {
    return googleRepo;
  } else {
    // 2. For Mobile, pass the googleRepo into the Explode wrapper
    final yt = ref.watch(youtubeClientProvider);
    return ExplodeYoutubeRepository(yt, fallback: googleRepo);
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
  // Keep the provider alive even on error to prevent the loop
  final keeper = ref.keepAlive();

  final repo = ref.watch(youtubeRepositoryProvider);

  try {
    final videos = await repo.fetchPlaylist(id);
    debugPrint('Successfully fetched ${videos.length} videos for $id');
    return videos;
  } catch (e) {
    debugPrint('YOUTUBE ERROR: $e');

    // If it fails, start a timer to allow disposal after 30 seconds,
    // but don't let it retry every millisecond in the meantime.
    Timer(const Duration(seconds: 30), () => keeper.close());

    rethrow;
  }
});
