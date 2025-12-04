import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/features/joys/models/joy.dart';

import 'package:abideverse/features/joys/widgets/display_title_section.dart';
import 'package:abideverse/features/joys/widgets/display_article_content.dart';
import 'package:abideverse/shared/widgets/display_youtube_video.dart';

class JoyDetailsScreen extends StatefulWidget {
  final Joy? joy;

  const JoyDetailsScreen({super.key, this.joy});

  @override
  State<JoyDetailsScreen> createState() => _JoyDetailsScreenState();
}

class _JoyDetailsScreenState extends State<JoyDetailsScreen> {
  bool favorite = false;

  late final joysRef = FirebaseFirestore.instance
      .collection(LocaleConstants.joystoreName)
      .withConverter<Joy>(
        fromFirestore: (snap, _) => Joy.fromJson(snap.data()!),
        toFirestore: (joy, _) => joy.toJson(),
      );

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance.logEvent(
      name: 'joy_details',
      parameters: widget.joy?.articleId != null
          ? {'articleId': widget.joy!.articleId!}
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final joy = widget.joy;
    if (joy == null) {
      return const Scaffold(body: Center(child: Text('No joy found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(joy.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ActionChip(
              avatar: const Icon(Icons.thumb_up_outlined, color: Colors.white),
              backgroundColor: Colors.green,
              label: Text(
                '${joy.likes}',
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (favorite) return;

                setState(() {
                  favorite = true;
                  joy.likes++;
                });

                final docRef = joysRef.doc(joy.articleId.toString());

                FirebaseFirestore.instance.runTransaction((tx) async {
                  final snap = await tx.get(docRef);
                  final newLikes = snap.get('likes') + 1;
                  tx.update(docRef, {'likes': newLikes});
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DisplayTitleSection(
              photoUrl: joy.photoUrl,
              title: joy.title,
              articleId: joy.articleId,
              scriptureVerse: joy.scriptureVerse,
              scriptureName: joy.scriptureName,
            ),
            DisplayArticleContent(title: '前奏曲', content: joy.prelude),
            DisplayArticleContent(title: '開懷大笑', content: joy.laugh),
            DisplayArticleContent(title: '笑裡藏道', content: joy.talk),
            DisplayYouTubeVideo(videoId: joy.videoId, videoName: joy.videoName),
          ],
        ),
      ),
    );
  }
}
