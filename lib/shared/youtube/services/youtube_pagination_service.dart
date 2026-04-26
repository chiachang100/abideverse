import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:abideverse/shared/youtube/data/youtube_repository.dart';

part 'youtube_pagination_service.g.dart';

@riverpod
class YoutubePagination extends _$YoutubePagination {
  bool _hasMore = true; // Add this private flag
  bool get hasMore => _hasMore;

  @override
  Future<List<Video>> build(String playlistId) async {
    _hasMore = true; // Reset when building for a new ID
    final repo = ref.watch(youtubeRepositoryProvider);
    final initial = await repo.fetchPlaylistBatch(
      playlistId,
      limit: 20,
      skip: 0,
    );
    if (initial.length < 20) _hasMore = false;
    return initial;
  }

  Future<void> fetchNextBatch() async {
    // Prevent multiple simultaneous fetches
    if (state.isLoading || !_hasMore) return;

    final currentVideos = state.value ?? [];
    final repo = ref.watch(youtubeRepositoryProvider);

    // Fetch the next 20 starting from the end of our current list
    final nextBatch = await repo.fetchPlaylistBatch(
      playlistId,
      limit: 20,
      skip: currentVideos.length,
    );

    if (nextBatch.isEmpty || nextBatch.length < 20) {
      _hasMore = false;
    }

    state = AsyncData([...currentVideos, ...nextBatch]);
  }
}
