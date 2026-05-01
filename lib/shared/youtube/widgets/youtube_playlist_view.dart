import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abideverse/shared/youtube/services/youtube_service.dart';
import 'package:abideverse/shared/youtube/widgets/youtube_player_screen.dart';
import 'package:abideverse/shared/youtube/services/youtube_pagination_service.dart';
import 'package:abideverse/shared/youtube/services/youtube_link_service.dart';
import 'package:abideverse/shared/youtube/data/app_video.dart';

class YoutubePlaylistView extends ConsumerStatefulWidget {
  final String playlistId;

  const YoutubePlaylistView({required this.playlistId, super.key});

  @override
  ConsumerState<YoutubePlaylistView> createState() =>
      _YoutubePlaylistViewState();
}

class _YoutubePlaylistViewState extends ConsumerState<YoutubePlaylistView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // 1. Check the current state of the pagination
      final asyncValue = ref.read(youtubePaginationProvider(widget.playlistId));

      // 2. ONLY proceed if we have valid data and ARE NOT currently in an error/loading state
      asyncValue.whenData((videos) {
        if (videos.isNotEmpty &&
            !asyncValue.isLoading &&
            !asyncValue.hasError) {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            ref
                .read(youtubePaginationProvider(widget.playlistId).notifier)
                .fetchNextBatch();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistAsync = ref.watch(
      youtubePaginationProvider(widget.playlistId),
    );

    // ACCESS THE NOTIFIER: We need to check the 'hasMore' flag we added to the service
    final paginationNotifier = ref.watch(
      youtubePaginationProvider(widget.playlistId).notifier,
    );
    final bool hasMore = paginationNotifier.hasMore;

    return playlistAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(child: Text('No videos found in this playlist.'));
        }

        return ListView.builder(
          controller: _scrollController,
          // DYNAMIC COUNT: If hasMore is true, we add 1 for the spinner. If false, we add 0.
          itemCount: videos.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // SPINNER LOGIC: Show spinner only if this is the last item and we have more to load
            if (index == videos.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final video = videos[index];

            // THUMBNAIL FIX: Using mediumResUrl for stability and ClipRRect for aesthetics
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  video
                      .thumbnails
                      .mediumResUrl, // Use medium for best balance of speed/quality
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  // FALLBACK: If the thumbnail fails to load, show a placeholder
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.video_library, color: Colors.grey),
                  ),
                ),
              ),
              title: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                video.author,
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YoutubePlayerScreen(
                      videoId: video.id,
                      title: video.title,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) {
        debugPrint('YOUTUBE VIEW ERROR: $e');

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'We couldn\'t load the playlist directly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This might be due to a connection issue or API limits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // --- THE LAST RESORT ---
                ElevatedButton.icon(
                  onPressed: () =>
                      YoutubeLinkService.launchPlaylist(widget.playlistId),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in YouTube'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
