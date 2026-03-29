// lib/features/treasures/screens/treasure_detail_page.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/features/treasures/data/treasure_repository.dart';
import 'package:abideverse/features/treasures/models/treasure.dart';
import 'package:abideverse/features/treasures/utils/treasure_share_utils.dart';
import 'package:abideverse/shared/widgets/display_article_content.dart';
import 'package:abideverse/shared/widgets/display_title_section.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class TreasureDetailPage extends StatefulWidget {
  final int articleId;
  final String locale;

  const TreasureDetailPage({
    super.key,
    required this.articleId,
    this.locale = LocaleConstants.defaultLocale,
  });

  @override
  State<TreasureDetailPage> createState() => _TreasureDetailPageState();
}

class _TreasureDetailPageState extends State<TreasureDetailPage> {
  Treasure? treasure;
  YoutubePlayerController? _youtubeController;

  bool isLoading = true;
  late TreasureRepository repository;

  @override
  void initState() {
    super.initState();
    repository = TreasureRepository(locale: widget.locale);
    loadTreasure();
  }

  Future<void> loadTreasure() async {
    final data = await repository.getTreasure(widget.articleId);

    setState(() {
      treasure = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (treasure == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.treasures.tr())),
        body: Center(
          child: Text(LocaleKeys.itemNotFound.tr()),
        ), // add translation key if available
      );
    }

    final s = treasure!;

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text('${s.articleId}. ${s.title}'),
        ),
        actions: [
          // Share Button
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: () => shareTreasure(s),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Treasure Meaning & Image section
            // Center(
            //   child: ClipRRect(
            //     borderRadius: const BorderRadius.vertical(
            //       bottom: Radius.circular(15),
            //     ),
            //     child: Image.asset(
            //       s.treasureImage,
            //       fit: BoxFit.contain,
            //       width: MediaQuery.of(context).size.width * 0.9,
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 16),
            // const Divider(),

            // /// Treasure Meaning
            // DisplayArticleContent(
            //   title: LocaleKeys.detailedMeaning.tr(),
            //   content: s.treasureMeaning,
            // ),
            DisplayTitleSection(
              title: LocaleKeys.detailedMeaning.tr(),
              content: s.treasureMeaning,
              imageUrl: s.treasureImage,
            ),

            /// Treasure Story
            DisplayArticleContent(
              title: LocaleKeys.detailedStory.tr(),
              content: s.treasureStory,
            ),

            /// Treasure RealLife
            DisplayArticleContent(
              title: LocaleKeys.detailedRealLife.tr(),
              content: s.treasureRealLife,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
