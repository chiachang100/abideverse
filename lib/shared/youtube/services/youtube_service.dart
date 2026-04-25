import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:abideverse/shared/youtube/data/youtube_repository.dart';

// The "Service" setup
final youtubeClientProvider = Provider.autoDispose<YoutubeExplode>((ref) {
  final client = YoutubeExplode();
  ref.onDispose(() => client.close());
  return client;
});

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) {
  final client = ref.watch(youtubeClientProvider);
  return YoutubeRepository(client);
});

// The reactive state that your UI will consume
final youtubePlaylistService = FutureProvider.family<List<Video>, String>((
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
