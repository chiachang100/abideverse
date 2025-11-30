import 'package:logging/logging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
//import 'package:web/helpers.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ypf;
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as ypi;

import '../data/data_index.dart';
import 'scripture_details.dart';

final abideverselogJoyDetails = Logger('joy_details');

class JoyDetailsScreen extends StatefulWidget {
  final Joy? joy;

  JoyDetailsScreen({super.key, this.joy});

  @override
  State<JoyDetailsScreen> createState() => _JoyDetailsScreenState();
}

class _JoyDetailsScreenState extends State<JoyDetailsScreen> {
  bool favorite = false;

  final joysRef =
      // FirebaseFirestore.instance.collection('joys').withConverter<Joy>(
      FirebaseFirestore.instance
          .collection(joystoreName)
          .withConverter<Joy>(
            fromFirestore: (snapshots, _) => Joy.fromJson(snapshots.data()!),
            toFirestore: (joy, _) => joy.toJson(),
          );

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'JoyDetailsScreen',
        'abideverse_screen_class': 'JoyDetailsScreenClass',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.joy == null) {
      return const Scaffold(body: Center(child: Text('No joy found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.joy!.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: ActionChip(
              avatar: const Icon(Icons.thumb_up_outlined, color: Colors.white),
              label: Text(
                '${widget.joy!.likes}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              tooltip: '點讚',
              onPressed: () {
                setState(() {
                  if (!favorite) {
                    favorite = true;
                    widget.joy!.likes++;
                    final joyRef = joysRef.doc(
                      widget.joy!.articleId.toString(),
                    );
                    FirebaseFirestore.instance.runTransaction((
                      transaction,
                    ) async {
                      final snapshot = await transaction.get(joyRef);
                      // final newLikes = snapshot.get('likes') + 1;
                      widget.joy!.likes = snapshot.get('likes') + 1;
                      transaction.update(joyRef, {'likes': widget.joy!.likes});
                    });
                  }
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
              photoUrl: widget.joy!.photoUrl,
              title: widget.joy!.title,
              articleId: widget.joy!.articleId,
              scriptureVerse: widget.joy!.scripture.verse,
              scriptureName: widget.joy!.scripture.name,
            ),
            DisplayArticleContent(title: '前奏曲', content: widget.joy!.prelude),
            DisplayArticleContent(title: '開懷大笑', content: widget.joy!.laugh),
            DisplayArticleContent(title: '笑裡藏道', content: widget.joy!.talk),
            DisplayYouTubeVideo(
              videoId: widget.joy!.videoId,
              videoName: widget.joy!.videoName,
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayTitleSection extends StatelessWidget {
  const DisplayTitleSection({
    super.key,
    required this.photoUrl,
    required this.title,
    required this.articleId,
    required this.scriptureVerse,
    required this.scriptureName,
  });
  final String photoUrl;
  final String title;
  final int articleId;
  final String scriptureVerse;
  final String scriptureName;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.yellow[50],
      elevation: 1.0,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Image.asset(
              photoUrl,
              height: MediaQuery.of(context).size.width * 3 / 4,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            '$title ($articleId)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          const SizedBox(height: 10),
          Text(
            '$scriptureVerse($scriptureName)',
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

class DisplayArticleContent extends StatelessWidget {
  const DisplayArticleContent({
    super.key,
    required this.title,
    required this.content,
  });
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.yellow[50],
      elevation: 1.0,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }
}

class DisplayYouTubeVideo extends StatelessWidget {
  const DisplayYouTubeVideo({
    super.key,
    required this.videoId,
    required this.videoName,
  });
  final String videoId;
  final String videoName;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.yellow[50],
      elevation: 1.0,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'YouTube視頻',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          const SizedBox(height: 10),
          Text(
            videoName,
            softWrap: true,
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 10),
          //YoutubePlayerIFrameSection(videoId: 'Mez7DnMOlgc', videoName: '不要怕！你要得人了 | 曾興才牧師 | 20240225 | 生命河 ROLCCmedia'),
          (useYoutubePlayerFlutterVersion && !kIsWeb)
              ? YoutubePlayerFlutterSection(
                  videoId: videoId,
                  videoName: videoName,
                )
              : YoutubePlayerIFrameSection(
                  videoId: videoId,
                  videoName: videoName,
                ),
        ],
      ),
    );
  }
}

/*
* YoutubePlayerIFrameSection uses [youtube_player_iframe](https://pub.dev/packages/youtube_player_iframe).
*/
class YoutubePlayerIFrameSection extends StatefulWidget {
  YoutubePlayerIFrameSection({required this.videoId, required this.videoName});
  final String videoId;
  final String videoName;

  @override
  State<YoutubePlayerIFrameSection> createState() =>
      _YoutubePlayerIFrameSectionState();
}

class _YoutubePlayerIFrameSectionState
    extends State<YoutubePlayerIFrameSection> {
  late ypi.YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'YoutubePlayerIFrameSection',
        'abideverse_screen_class': 'JoyDetailsScreenClass',
      },
    );

    _controller = ypi.YoutubePlayerController(
      params: const ypi.YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    _controller.setFullScreenListener((isFullScreen) {
      // developer.log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
      abideverselogJoyDetails.fine(
        '${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.',
      );
    });

    //_controller.loadVideoById(videoId: widget.videoId); // Auto Play
    _controller.cueVideoById(videoId: widget.videoId); // Manual Play

    abideverselogJoyDetails.info('[JoyDetails] Using YoutubePlayerIFrame.');
  }

  @override
  void dispose() {
    try {
      _controller.close();
      super.dispose();
    } catch (e) {
      //abideverselogJoyDetails.info('[JoyDetails] Caught exception: $e');
      abideverselogJoyDetails.info(
        '[JoyDetails] YoutubePlayerIFrame: Caught exception...',
      );
    } finally {
      //super.dispose();
    }
  }

  // final _controller = YoutubePlayerController(
  @override
  Widget build(BuildContext context) {
    return ypi.YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: <Widget>[
            // Text(
            //   '(${widget.videoName})',
            //   softWrap: true,
            //   style: const TextStyle(
            //     fontSize: 12.0,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            player,
          ],
        ),
      ),
    );
  }
}

//
// YoutubePlayerFlutterSection uses [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter).
// Only works for Android and iOS. Web was failed. See README.md file for detailed information.
//
class YoutubePlayerFlutterSection extends StatefulWidget {
  const YoutubePlayerFlutterSection({
    super.key,
    required this.videoId,
    required this.videoName,
  });
  final String videoId;
  final String videoName;

  @override
  State<YoutubePlayerFlutterSection> createState() =>
      _YoutubePlayerFlutterSectionState();
}

class _YoutubePlayerFlutterSectionState
    extends State<YoutubePlayerFlutterSection> {
  late ypf.YoutubePlayerController _controller;
  bool isFullScreen = false;

  //videoId = ypf.YoutubePlayer.convertUrlToId("https://www.youtube.com/watch?v=BBAyRBTfsOU");

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'YoutubePlayerFlutterSection',
        'abideverse_screen_class': 'JoyDetailsScreenClass',
      },
    );

    _controller =
        ypf.YoutubePlayerController(
          initialVideoId: widget.videoId,
          flags: const ypf.YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            //isLive: true,
          ),
        )..addListener(() {
          if (_controller.value.isFullScreen != isFullScreen) {
            setState(() {
              isFullScreen = _controller.value.isFullScreen;
            });
          }
        });

    abideverselogJoyDetails.info('[JoyDetails] Using YoutubePlayerFlutter.');
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
      super.dispose();
    } catch (e) {
      //abideverselogJoyDetails.info('[JoyDetails] Caught exception: $e');
      abideverselogJoyDetails.info(
        '[JoyDetails] YoutubePlayerFlutter: Caught exception...',
      );
    } finally {
      //super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ypf.YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        setState(() {
          isFullScreen = false;
        });
      },
      player: ypf.YoutubePlayer(
        controller: _controller,
        liveUIColor: Colors.amber,
        showVideoProgressIndicator: true,
        aspectRatio: 16 / 9,
      ),
      builder: (context, player) => Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: <Widget>[
            // Text(
            //   '(${widget.videoName})',
            //   softWrap: true,
            //   style: const TextStyle(
            //     fontSize: 12.0,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            player,
          ],
        ),
      ),
    );
  }
}
