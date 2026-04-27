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
      {'title': '日富一日背誦聖經 Shorts', 'id': 'PLFyg5v4HpNhWy6JkmAPhEML1N1gH-Q5jv'},
      {'title': '曾興才牧師講道集', 'id': 'PLFyg5v4HpNhVEKQd7IGhXmz_a4dEbQgme'},
      {
        'title': '主的喜樂(joyolord)-中文詩歌',
        'id': 'PLFyg5v4HpNhW7FCTafVkB_jH1Lm7ZhBv3',
      },
      {
        'title': '主的喜樂(joyolord)-English_Hymns',
        'id': 'PLFyg5v4HpNhX9jZfRTKD9pDLnVb4MTW2Z',
      },
      {
        'title': 'Hymns for the Soul In English & Chinese',
        'id': 'PLFyg5v4HpNhWah9MwwJNHyTNl0-SrJf3g',
      },
      {
        'title': '優美食 - 巧手家常菜 (優視頻道)',
        'id': 'PL0ua7D5NJtvVBYciPwuC3lQxomrTlbqS0',
      },
      {'title': '2026 誰來作客 (優視頻道)', 'id': 'PLPR_qC7y5PLujUWJYoGqWr6w3zRBcPJ9X'},

      /* 
      {'title': '', 'id': ''},

      {
        'title': '焦點新聞 - 帶您來關心最新全球新聞焦點 (優視頻道)',
        'id': 'PLw09jf23adiGZAuPOAHVnauCLlokJpFFf',
      },
      {'title': '龍門陣直播 (優視頻道)', 'id': 'PLZxghdYE0TEPvmZ-xPKF4g30WpqztrHvI'},
      {'title': '焦點財經 (優視頻道)', 'id': 'PLV66nvIGRo-Tv4X5_Wrd7y1H2V-tYoVHh'},

      {
        'title': 'AI 新時代 // AI 來了 - 掌握AI，就是掌握未來 (優視頻道)',
        'id': 'PLvrKRwXvxwNqAcCFR97PHJkdw9Q2EyLSl',
      } 
      {
        'title': '焦點話題 - 老章陪你看新聞 (優視頻道)',
        'id': 'PLG4UBWNLO49iJ05lOPFLvRjPZN4ciCU0o',
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
      {
        'title': '2025聖誕嘉年華特輯 (優視頻道)',
        'id': 'PLvrKRwXvxwNpDpMX-QYsGdfvszPsDA9ET',
      }, 
      */
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
