import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:abideverse/shared/youtube/services/youtube_service.dart'; // Import where your manual provider lives
import 'package:abideverse/shared/youtube/data/app_video.dart';

part 'youtube_pagination_service.g.dart';

@riverpod
class YoutubePagination extends _$YoutubePagination {
  String? _nextPageToken;
  bool _hasMore = true; // Add this private flag
  bool _errorLock = false; // The Circuit Breaker
  bool get hasMore => _hasMore;

  DateTime? _lastFetchAttempt;

  @override
  Future<List<AppVideo>> build(String playlistId) async {
    // THIS IS THE KEY: It forces Riverpod to cache the Error state
    // so it doesn't call build() again until you manually invalidate it.
    ref.keepAlive();

    _nextPageToken = null;
    _hasMore = true; // Reset when building for a new ID
    _errorLock = false; // Reset

    final repo = ref.watch(youtubeRepositoryProvider);

    try {
      final (initialBatch, nextToken) = await repo.fetchPlaylistBatch(
        playlistId,
        limit: 20,
        pageToken: null, // First page has no token
      );

      _nextPageToken = nextToken;
      _hasMore = nextToken != null;

      return initialBatch;
    } catch (e, st) {
      _errorLock = true; // Block further attempts
      debugPrint("[Pagination] Caught initial error: $e");
      rethrow;
    }
  }

  Future<void> fetchNextBatch() async {
    final now = DateTime.now();

    // If we tried to fetch in the last 2 seconds, ignore this request.
    if (_lastFetchAttempt != null &&
        now.difference(_lastFetchAttempt!) < const Duration(seconds: 2)) {
      return;
    }

    _lastFetchAttempt = now;

    // Prevent multiple simultaneous fetches
    if (state.isLoading || !_hasMore || state.hasError) return;

    final currentVideos = state.value ?? [];
    final repo = ref.read(youtubeRepositoryProvider);

    try {
      // Fetch the next 20 starting from the end of our current list
      final (nextBatch, nextToken) = await repo.fetchPlaylistBatch(
        playlistId,
        limit: 20,
        pageToken: _nextPageToken,
      );
      _nextPageToken = nextToken;
      _hasMore = nextToken != null;

      state = AsyncValue.data([...currentVideos, ...nextBatch]);
    } catch (e, st) {
      _errorLock = true; // LOCK IT
      state = AsyncValue.error(e, st);
    }
  }

  // Add this to be called by your "Try Again" button
  void retry() {
    _errorLock = false;
    fetchNextBatch();
  }
}
