import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:abideverse/features/gallery/screens/playlist_detail_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Curated playlists for the AbideVerse Gallery
    final galleryItems = [
      {'title': '日富一日背誦聖經 Shorts', 'id': 'PLKdEkGc8_SfF1gfJAFamxM_PLLCTEUsEr'},
      {'title': '曾興才牧師講道集', 'id': 'PLFyg5v4HpNhVEKQd7IGhXmz_a4dEbQgme'},
      {
        'title': '主的喜樂(joyolord)-Chinese_Hymns',
        'id': 'PLFyg5v4HpNhW7FCTafVkB_jH1Lm7ZhBv3',
      },
      {
        'title': '主的喜樂(joyolord)-English_Hymns',
        'id': 'PLFyg5v4HpNhX9jZfRTKD9pDLnVb4MTW2Z',
      },
      {'title': 'Test 2025聖誕嘉年華特輯', 'id': 'PLvrKRwXvxwNpDpMX-QYsGdfvszPsDA9ET'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Abide Gallery')),
      body: ListView.builder(
        itemCount: galleryItems.length,
        itemBuilder: (context, index) {
          final item = galleryItems[index];
          return ListTile(
            title: Text(item['title']!),
            // onTap: () => Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => PlaylistDetailScreen(
            //       title: item['title']!,
            //       playlistId: item['id']!,
            //     ),
            //   ),
            // ),
            onTap: kIsWeb
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'YouTube Gallery is coming soon to the Web version!',
                        ),
                      ),
                    );
                  }
                : () {
                    // Normal navigation for Mobile/Desktop
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(
                          title: item['title']!,
                          playlistId: item['id']!,
                        ),
                      ),
                    );
                  },
          );
        },
      ),
    );
  }
}
