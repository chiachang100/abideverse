import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ypf;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as ypi;

import 'package:abideverse/core/config/app_config.dart';
import 'package:logging/logging.dart';

final _log = Logger('youtube_player');

/// Unified YouTube player for both mobile and web.
class YoutubePlayerWidget extends StatelessWidget {
  final String videoId;
  final String videoName;

  const YoutubePlayerWidget({
    super.key,
    required this.videoId,
    required this.videoName,
  });

  @override
  Widget build(BuildContext context) {
    final useFlutterPlayer = AppConfig.useYoutubePlayerFlutter && !kIsWeb;

    return useFlutterPlayer
        ? YoutubePlayerFlutter(videoId: videoId, videoName: videoName)
        : YoutubePlayerIFrame(videoId: videoId, videoName: videoName);
  }
}

/* -------------------------------------------------------------------------- */
/*                          YoutubePlayerIframe (Web)                         */
/* -------------------------------------------------------------------------- */

class YoutubePlayerIFrame extends StatefulWidget {
  final String videoId;
  final String videoName;

  const YoutubePlayerIFrame({
    super.key,
    required this.videoId,
    required this.videoName,
  });

  @override
  State<YoutubePlayerIFrame> createState() => _YoutubePlayerIFrameState();
}

class _YoutubePlayerIFrameState extends State<YoutubePlayerIFrame> {
  late ypi.YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'youtube_iframe',
      parameters: {'videoId': widget.videoId},
    );

    _controller = ypi.YoutubePlayerController(
      params: const ypi.YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
      ),
    );

    _controller.cueVideoById(videoId: widget.videoId);
  }

  @override
  void dispose() {
    try {
      _controller.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ypi.YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) =>
          Padding(padding: const EdgeInsets.all(12), child: player),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                        YoutubePlayerFlutter (iOS/Android)                  */
/* -------------------------------------------------------------------------- */

class YoutubePlayerFlutter extends StatefulWidget {
  final String videoId;
  final String videoName;

  const YoutubePlayerFlutter({
    super.key,
    required this.videoId,
    required this.videoName,
  });

  @override
  State<YoutubePlayerFlutter> createState() => _YoutubePlayerFlutterState();
}

class _YoutubePlayerFlutterState extends State<YoutubePlayerFlutter> {
  late ypf.YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ypf.YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const ypf.YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ypf.YoutubePlayerBuilder(
      player: ypf.YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) =>
          Padding(padding: const EdgeInsets.all(12), child: player),
    );
  }
}
