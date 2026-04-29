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

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Curated playlists for the AbideVerse Gallery
    final galleryItems = [
      {
        'title': '日富一日背誦聖經 Shorts',
        'subtitle': '神的話語，每日靈糧，積累屬天財富。',
        'id': 'PLFyg5v4HpNhWy6JkmAPhEML1N1gH-Q5jv',
      },
      {
        'title': '矽谷生命河靈糧堂 曾興才牧師講道集',
        'subtitle': '生命河流，真理餵養，活出豐盛人生。',
        'id': 'PLFyg5v4HpNhVEKQd7IGhXmz_a4dEbQgme',
      },
      {
        'title': '主的喜樂(joyolord)-中文詩歌',
        'subtitle': '心靈誠實，敬拜讚美，歌頌主愛無疆。',
        'id': 'PLFyg5v4HpNhW7FCTafVkB_jH1Lm7ZhBv3',
      },
      {
        'title': '主的喜樂(joyolord)-English_Hymns',
        'subtitle':
            'Spirit and Truth, Worship and Praise, Abiding in His Grace.',
        'id': 'PLFyg5v4HpNhX9jZfRTKD9pDLnVb4MTW2Z',
      },
      {
        'title': 'Hymns for the Soul In English & Chinese',
        'subtitle': '10 Inspired Hymns: Billy Graham Crusade Legacy.',
        'id': 'PLFyg5v4HpNhWah9MwwJNHyTNl0-SrJf3g',
      },
      {
        'title': '優美食',
        'subtitle': '巧手家常菜 (優視頻道)',
        'id': 'PL0ua7D5NJtvVBYciPwuC3lQxomrTlbqS0',
      },
      {
        'title': '焦點新聞',
        'subtitle': '帶您來關心最新全球新聞焦點 (優視頻道)',
        'id': 'PLw09jf23adiGZAuPOAHVnauCLlokJpFFf',
      },

      /* 
      {'title': '', 'subtitle': '', 'id': ''},

      {'title': '2026 誰來作客 (優視頻道)', 'subtitle': '', 'id': 'PLPR_qC7y5PLujUWJYoGqWr6w3zRBcPJ9X'},
      {'title': '龍門陣直播 (優視頻道)', 'subtitle': '', 'id': 'PLZxghdYE0TEPvmZ-xPKF4g30WpqztrHvI'},
      {'title': '焦點財經 (優視頻道)', 'subtitle': '', 'id': 'PLV66nvIGRo-Tv4X5_Wrd7y1H2V-tYoVHh'},

      {
        'title': 'AI 新時代 (優視頻道)',
        'subtitle': 'AI 新時代 // AI 來了 - 掌握AI，就是掌握未來',
        'id': 'PLvrKRwXvxwNqAcCFR97PHJkdw9Q2EyLSl',
      } 
      {
        'title': '焦點話題 (優視頻道)',
        'subtitle': '老章陪你看新聞',
        'id': 'PLG4UBWNLO49iJ05lOPFLvRjPZN4ciCU0o',
      },
      {
        'title': '優視特別活動 // Special Event (優視頻道)',
        'subtitle': '',
        'id': 'PLvrKRwXvxwNqT3iRu8eC4pfIMWKSuy5-i',
      },
      {'title': '性別神學講座 (優視頻道)', 'subtitle': '', 'id': 'PLvrKRwXvxwNrQKqUB508U4Vm4MR6DvSOF'},
      {'title': '矽谷龍門陣 (優視頻道)', 'subtitle': '', 'id': 'PLvrKRwXvxwNrnQ7cjnIuAq11rGQ0Jgsrj'},
      {
        'title': '優視SPOTLIGHT (優視頻道)',
        'subtitle': '',
        'id': 'PLvrKRwXvxwNpM2-O2S_7WFRvwsE8rn4mH',
      },
      {
        'title': '2025聖誕嘉年華特輯 (優視頻道)',
        'subtitle': '',
        'id': 'PLvrKRwXvxwNpDpMX-QYsGdfvszPsDA9ET',
      }, 
      */
    ];

    final externalResources = [
      {
        'title': '矽谷生命河靈糧堂',
        'subtitle': '異象: 建造神榮耀的教會。 策略: 敬拜讚美、聖靈更新、小組教會、全地轉化。',
        'url': 'https://rolcc.net/',
      },
      {
        'title': 'UChannel TV 優視頻道',
        'subtitle': '優視頻道是全美#1華人非營利、全方位、生活頻道。',
        'url': 'https://www.uchanneltv.us/',
      },
      {
        'title': 'GOOD TV',
        'subtitle': 'GOOD TV 好消息電視台',
        'url': 'https://www.youtube.com/user/goodtv',
      },

      /* 

      {
        'title': 'UChannel Live Stream',
        'subtitle': '優視頻道 24/7 直播',
        'url':
            'https://c.streamhoster.com/embed/media/WksBy6/IRBKmbjFsDA/K0xz4KschTb_5',
      },
      {
        'title': '聖經朗讀資源',
        'subtitle': '更多屬靈餵養資源',
        'url': 'https://www.biblegateway.com/',
      },

      */
    ];

    return Scaffold(
      appBar: AbideAppBar(title: LocaleKeys.gallery.tr()),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          // SECTION 1: YouTube Playlists
          ...galleryItems.asMap().entries.map((entry) {
            final item = entry.value;

            return GalleryListItem(
              index: entry.key,
              title: item['title']!,
              subtitle: item['subtitle'] ?? '',
              onTap: kIsWeb
                  ? () => YoutubeLinkService.launchPlaylist(item['id']!)
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(
                          title: item['title']!,
                          playlistId: item['id']!,
                        ),
                      ),
                    ),
            );
          }).toList(),

          const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),

          // SECTION 2: External Resources Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              LocaleKeys.moreConnections.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // SECTION 3: External URLs
          //...externalResources.map((item) {
          ...externalResources.asMap().entries.map((entry) {
            final item = entry.value;

            return GalleryListItem(
              index: entry.key,
              isExternal: true,
              title: item['title']!,
              subtitle: item['subtitle'] ?? '',
              onTap: () => UrlService.launch(item['url']!),
            );
          }).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
