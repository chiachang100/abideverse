import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

import 'package:abideverse/features/gallery/screens/playlist_detail_screen.dart';
import 'package:abideverse/features/gallery/widgets/gallery_list_item.dart';
import 'package:abideverse/shared/youtube/services/youtube_link_service.dart';
import 'package:abideverse/shared/services/url_service.dart';

import 'package:abideverse/shared/widgets/shared_app_bar.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';

import 'package:abideverse/features/gallery/data/gallery_repository.dart';
import 'package:abideverse/features/gallery/models/gallery_item.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = GalleryRepository();
    final items = repository.getGalleryItems();

    return Scaffold(
      appBar: AbideAppBar(title: LocaleKeys.gallery.tr()),
      drawer: const AppDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) {
          // Check if we are at the transition point:
          // The current item is a Playlist AND the next item is an External Link
          if (index < items.length - 1 &&
              items[index].isPlaylist &&
              !items[index + 1].isPlaylist) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  height: 40,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    LocaleKeys.moreConnections
                        .tr(), // Using your localization key
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }

          // Default spacing between items of the same type
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          final item = items[index];

          return GalleryListItem(
            index: index,
            isExternal: !item.isPlaylist,
            title: item.title,
            subtitle: item.subtitle,
            onTap: () {
              if (item.isPlaylist) {
                // Calling the private helper method here
                _handlePlaylistLaunch(context, item.title, item.target);
              } else {
                UrlService.launch(item.target);
              }
            },
          );
        },
      ),
    );
  }

  /// Private Helper Method: Keeps the build method clean
  void _handlePlaylistLaunch(
    BuildContext context,
    String title,
    String playlistId,
  ) {
    const apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

    // Web Fallback: If no API key is present, open YouTube directly
    if (kIsWeb && apiKey.isEmpty) {
      debugPrint(
        "[GalleryScreen] Web Fail-safe: No API Key, using YoutubeLinkService.",
      );
      YoutubeLinkService.launchPlaylist(playlistId);
    } else {
      // Normal Navigation: Push to the internal detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PlaylistDetailScreen(title: title, playlistId: playlistId),
        ),
      );
    }
  }
}
