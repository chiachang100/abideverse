import 'package:abideverse/shared/widgets/youtube_player.dart';
import 'package:flutter/material.dart';

class DisplayYouTubeVideo extends StatelessWidget {
  final String videoId;
  final String videoName;

  const DisplayYouTubeVideo({
    super.key,
    required this.videoId,
    required this.videoName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'YouTube 視頻',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(videoName, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            YoutubePlayerWidget(videoId: videoId, videoName: videoName),
          ],
        ),
      ),
    );
  }
}
