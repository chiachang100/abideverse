import 'package:flutter/material.dart';
import 'package:abideverse/shared/youtube/widgets/youtube_playlist_view.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String title;
  final String playlistId;

  const PlaylistDetailScreen({
    super.key,
    required this.title,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(title),
        ),
      ),
      body: YoutubePlaylistView(playlistId: playlistId),
    );
  }
}
