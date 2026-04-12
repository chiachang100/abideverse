// lib/features/scriptures/screens/scripture_detail_page.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:abideverse/features/scriptures/data/scripture_repository.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/features/scriptures/utils/scripture_share_utils.dart';
import 'package:abideverse/shared/widgets/display_article_content.dart';
import 'package:abideverse/shared/widgets/display_youtube_video.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/constants/locale_constants.dart';

class ScriptureDetailPage extends StatefulWidget {
  final int articleId;
  final String locale;

  const ScriptureDetailPage({
    super.key,
    required this.articleId,
    this.locale = LocaleConstants.defaultLocale,
  });

  @override
  State<ScriptureDetailPage> createState() => _ScriptureDetailPageState();
}

class _ScriptureDetailPageState extends State<ScriptureDetailPage> {
  Scripture? scripture;
  YoutubePlayerController? _youtubeController;

  bool isDone = false; // Task state
  bool isLoading = true;
  late ScriptureRepository repository;

  @override
  void initState() {
    super.initState();
    repository = ScriptureRepository(locale: widget.locale);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await repository.getScripture(widget.articleId);
    final prefs = await SharedPreferences.getInstance();
    final doneList = prefs.getStringList('scriptures_done_status') ?? [];

    if (data != null && data.videoId.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: data.videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }

    setState(() {
      scripture = data;
      isDone = doneList.contains(widget.articleId.toString());
      isLoading = false;
    });
  }

  Future<void> _toggleStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final doneList = (prefs.getStringList('scriptures_done_status') ?? [])
        .toSet();
    final id = widget.articleId.toString();

    setState(() {
      isDone = !isDone;
      if (isDone) {
        doneList.add(id);
      } else {
        doneList.remove(id);
      }
    });
    await prefs.setStringList('scriptures_done_status', doneList.toList());
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

    if (scripture == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.bibleVerse.tr())),
        body: Center(
          child: Text(LocaleKeys.itemNotFound.tr()),
        ), // add translation key if available
      );
    }

    final s = scripture!;

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text('${s.articleId}. ${s.title}'),
        ),
        actions: [
          // Mark Done Button
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8),
          //   child: ActionChip(
          //     avatar: Icon(
          //       isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          //       color: Colors.white,
          //       size: 18,
          //     ),
          //     backgroundColor: isDone ? Colors.green : Colors.grey,
          //     label: Text(
          //       isDone ? LocaleKeys.done.tr() : LocaleKeys.markDone.tr(),
          //       style: const TextStyle(color: Colors.white),
          //     ),
          //     onPressed: _toggleStatus,
          //   ),
          // ),

          // Share Button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => shareScripture(s),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Scripture verse + name + chapter + zhCNScriptureVerse
            DisplayArticleContent(
              title: LocaleKeys.bibleVerseHeader.tr(),
              content:
                  '''
✞ ${s.scriptureVerse} (${s.scriptureName} ${s.scriptureChapter})

✞ ${s.zhCNScriptureVerse}''',
            ),

            /// YouTube section
            if (s.videoId.isNotEmpty) ...[
              DisplayYouTubeVideo(videoId: s.videoId, videoName: s.videoName),
            ] else
              Text(LocaleKeys.noVideoAvailable.tr()),
          ],
        ),
      ),
    );
  }
}
