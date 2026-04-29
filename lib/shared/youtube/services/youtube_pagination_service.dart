import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:abideverse/shared/youtube/services/youtube_service.dart'; // Import where your manual provider lives
import 'package:abideverse/shared/youtube/data/app_video.dart';

part 'youtube_pagination_service.g.dart';

@riverpod
class YoutubePagination extends _$YoutubePagination {
  String? _nextPageToken;
  bool _hasMore = true; // Add this private flag
  bool get hasMore => _hasMore;

  @override
  Future<List<AppVideo>> build(String playlistId) async {
    _nextPageToken = null;
    _hasMore = true; // Reset when building for a new ID

    final repo = ref.watch(youtubeRepositoryProvider);
    final (initialBatch, nextToken) = await repo.fetchPlaylistBatch(
      playlistId,
      limit: 20,
      pageToken: null, // First page has no token
    );

    _nextPageToken = nextToken;
    _hasMore = nextToken != null;

    return initialBatch;
  }

  Future<void> fetchNextBatch() async {
    // Prevent multiple simultaneous fetches
    if (state.isLoading || !_hasMore) return;

    final currentVideos = state.value ?? [];
    final repo = ref.watch(youtubeRepositoryProvider);

    // Fetch the next 20 starting from the end of our current list
    final (nextBatch, nextToken) = await repo.fetchPlaylistBatch(
      playlistId,
      limit: 20,
      pageToken: _nextPageToken,
    );
    _nextPageToken = nextToken;
    _hasMore = nextToken != null;

    state = AsyncValue.data([...currentVideos, ...nextBatch]);
  }
}
