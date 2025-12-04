// lib/features/scriptures/screens/detailed_scripture_page.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:abideverse/features/scriptures/data/scripture_repository.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/shared/widgets/display_youtube_video.dart';

class DetailedScripturePage extends StatefulWidget {
  final int articleId;
  final String locale;

  const DetailedScripturePage({
    Key? key,
    required this.articleId,
    this.locale = 'zh-TW',
  }) : super(key: key);

  @override
  State<DetailedScripturePage> createState() => _DetailedScripturePageState();
}

class _DetailedScripturePageState extends State<DetailedScripturePage> {
  Scripture? scripture;
  YoutubePlayerController? _youtubeController;

  bool isLoading = true;
  late ScriptureRepository repository;

  @override
  void initState() {
    super.initState();
    repository = ScriptureRepository(locale: widget.locale);
    loadScripture();
  }

  Future<void> loadScripture() async {
    final data = await repository.getScripture(widget.articleId);

    if (data != null && data.videoId.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: data.videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }

    setState(() {
      scripture = data;
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

    if (scripture == null) {
      return const Scaffold(body: Center(child: Text('Scripture not found')));
    }

    final s = scripture!;

    return Scaffold(
      appBar: AppBar(title: const Text('Bible Verse')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              '${s.title} (${s.articleId})${s.isRicherDaily ? " *" : ""}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// Scripture name + chapter
            Text(
              '${s.scriptureName} ${s.scriptureChapter}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            /// Verse text
            Text(
              '${s.scriptureVerse} (${s.scriptureName} ${s.scriptureChapter})',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            /// YouTube section
            if (s.videoId.isNotEmpty) ...[
              DisplayYouTubeVideo(videoId: s.videoId, videoName: s.videoName),

              // Text(
              //   'YouTube Video: ${s.videoName}',
              //   style: const TextStyle(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),

              // YoutubePlayer(
              //   controller: _youtubeController!,
              //   showVideoProgressIndicator: true,
              //   progressIndicatorColor: Colors.red,
              // ),
            ] else
              const Text("No video available."),
          ],
        ),
      ),
    );
  }
}
