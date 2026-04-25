import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abideverse/shared/youtube/services/youtube_service.dart';

import 'package:abideverse/shared/widgets/youtube_player.dart';

class YoutubePlaylistView extends ConsumerWidget {
  final String playlistId;

  const YoutubePlaylistView({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the "Service" here
    final playlistAsync = ref.watch(youtubePlaylistService(playlistId));

    return playlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      // ADD/UPDATE THIS SECTION HERE:
      error: (err, stack) {
        debugPrint('UI Error Display: $err');
        // This will show the actual error message on your phone screen
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading videos: $err',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },

      data: (videos) {
        // 1. Handle the Empty State
        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('This content format is not supported in-app yet.'),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => YoutubePlayerWidget(
                    videoId: playlistId,
                    videoName: 'videoName',
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View on YouTube'),
                ),
              ],
            ),
          );
        }

        // 2. Build the list if there ARE videos
        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            // Safe thumbnail check
            final thumbnailUrl = video.thumbnails.lowResUrl.isNotEmpty
                ? video.thumbnails.lowResUrl
                : 'https://via.placeholder.com/150'; // Fallback image

            return ListTile(
              leading: Image.network(thumbnailUrl),
              title: Text(video.title),
              subtitle: Text(video.duration?.toString() ?? 'Shorts'),
            );
          },
        );
      },
    );
  }
}
