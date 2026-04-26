import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

import 'package:abideverse/features/gallery/screens/playlist_detail_screen.dart';
import 'package:abideverse/features/gallery/widgets/gallery_list_item.dart';
import 'package:abideverse/shared/youtube/services/youtube_link_service.dart';

import 'package:abideverse/shared/widgets/shared_app_bar.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Curated playlists for the AbideVerse Gallery
    final galleryItems = [
      //{'title': '日富一日背誦聖經 Shorts', 'id': 'PLKdEkGc8_SfF1gfJAFamxM_PLLCTEUsEr'},
      {'title': '日富一日背誦聖經 Shorts', 'id': 'PLFyg5v4HpNhWy6JkmAPhEML1N1gH-Q5jv'},
      {'title': '曾興才牧師講道集', 'id': 'PLFyg5v4HpNhVEKQd7IGhXmz_a4dEbQgme'},
      {
        'title': 'AI 新時代 // AI 來了 - 掌握AI，就是掌握未來 (優視頻道)',
        'id': 'PLvrKRwXvxwNqAcCFR97PHJkdw9Q2EyLSl',
      },
      {
        'title': '優視特別活動 // Special Event (優視頻道)',
        'id': 'PLvrKRwXvxwNqT3iRu8eC4pfIMWKSuy5-i',
      },
      {'title': '性別神學講座 (優視頻道)', 'id': 'PLvrKRwXvxwNrQKqUB508U4Vm4MR6DvSOF'},
      {'title': '矽谷龍門陣 (優視頻道)', 'id': 'PLvrKRwXvxwNrnQ7cjnIuAq11rGQ0Jgsrj'},
      {
        'title': '優視SPOTLIGHT (優視頻道)',
        'id': 'PLvrKRwXvxwNpM2-O2S_7WFRvwsE8rn4mH',
      },
      // {
      //   'title': '2025聖誕嘉年華特輯 (優視頻道)',
      //   'id': 'PLvrKRwXvxwNpDpMX-QYsGdfvszPsDA9ET',
      // },
    ];

    return Scaffold(
      appBar: AbideAppBar(title: LocaleKeys.gallery.tr()),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: galleryItems.length,
        itemBuilder: (context, index) {
          final item = galleryItems[index];

          return GalleryListItem(
            index: index,
            title: item['title']!,
            onTap: kIsWeb
                ? () =>
                      YoutubeLinkService.launchPlaylist(
                        item['id']!,
                      ) // Direct to YouTube on Web
                : () {
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
