import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abideverse/shared/youtube/services/youtube_service.dart';
import 'package:abideverse/shared/youtube/widgets/youtube_player_screen.dart';
import 'package:abideverse/shared/youtube/services/youtube_pagination_service.dart';

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
      // If we are within 200 pixels of the bottom, load more
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(youtubePaginationProvider(widget.playlistId).notifier)
            .fetchNextBatch();
      }
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
                      videoId: video.id.value,
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
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
