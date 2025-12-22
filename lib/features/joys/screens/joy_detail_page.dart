import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/features/joys/models/joy.dart';

import 'package:abideverse/shared/widgets/display_youtube_video.dart';
import 'package:abideverse/features/joys/widgets/display_title_section.dart';
import 'package:abideverse/features/joys/widgets/display_article_content.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class JoyDetailPage extends StatefulWidget {
  final int articleId;
  final String locale;

  const JoyDetailPage({
    super.key,
    required this.articleId,
    this.locale = LocaleConstants.defaultLocale,
  });

  @override
  State<JoyDetailPage> createState() => _JoyDetailPageState();
}

class _JoyDetailPageState extends State<JoyDetailPage> {
  Joy? joy;
  bool isLoading = true;
  bool favorite = false;

  late JoyRepository repository;

  @override
  void initState() {
    super.initState();
    repository = JoyRepository(locale: widget.locale);
    loadJoy();
  }

  Future<void> loadJoy() async {
    final data = await repository.getJoy(widget.articleId);

    setState(() {
      joy = data;
      isLoading = false;
    });
  }

  /// Local-only likes (not stored anywhere)
  void _incrementLikes() {
    if (!AppConfig.enableLikeButton) return;
    if (favorite || joy == null) return;

    setState(() {
      favorite = true;
      joy!.likes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (joy == null) {
      return const Scaffold(body: Center(child: Text('Joy not found')));
    }

    if (joy == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.xlcd.tr())),
        body: Center(
          child: Text(LocaleKeys.itemNotFound.tr()),
        ), // add translation key if available
      );
    }

    final j = joy!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${j.articleId}. ${j.title}',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          if (AppConfig.enableLikeButton)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ActionChip(
                avatar: const Icon(
                  Icons.thumb_up_outlined,
                  color: Colors.white,
                ),
                backgroundColor: Colors.green,
                label: Text(
                  '${j.likes}',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: _incrementLikes,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Shared Title Section (image + title + scripture info)
            DisplayTitleSection(joy: j),

            const SizedBox(height: 1),

            /// Article sections
            DisplayArticleContent(
              title: LocaleKeys.detailedPrelude.tr(),
              content: j.prelude,
            ),
            DisplayArticleContent(
              title: LocaleKeys.detailedLaugh.tr(),
              content: j.laugh,
              addEmoji: true,
            ),
            DisplayArticleContent(title: LocaleKeys.joys.tr(), content: j.talk),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            /// YouTube video
            if (j.videoId.isNotEmpty)
              DisplayYouTubeVideo(videoId: j.videoId, videoName: j.videoName)
            else
              Text(LocaleKeys.noVideoAvailable.tr()),
          ],
        ),
      ),
    );
  }
}
