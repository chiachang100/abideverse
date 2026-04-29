import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
  final bool autoPop;

  const YoutubePlayerWidget({
    super.key,
    required this.videoId,
    required this.videoName,
    this.autoPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final useFlutterPlayer = AppConfig.useYoutubePlayerFlutter && !kIsWeb;

    return useFlutterPlayer
        ? YoutubePlayerFlutter(
            videoId: videoId,
            videoName: videoName,
            autoPop: autoPop,
          )
        : YoutubePlayerIFrame(
            videoId: videoId,
            videoName: videoName,
            autoPop: autoPop,
          );
  }
}

/* -------------------------------------------------------------------------- */
/*                          YoutubePlayerIframe (Web)                         */
/* -------------------------------------------------------------------------- */

class YoutubePlayerIFrame extends StatefulWidget {
  final String videoId;
  final String videoName;
  final bool autoPop;

  const YoutubePlayerIFrame({
    super.key,
    required this.videoId,
    required this.videoName,
    this.autoPop = false,
  });

  @override
  State<YoutubePlayerIFrame> createState() => _YoutubePlayerIFrameState();
}

class _YoutubePlayerIFrameState extends State<YoutubePlayerIFrame> {
  late ypi.YoutubePlayerController _controller;
  StreamSubscription? _subscription; // Track the sub

  @override
  void initState() {
    super.initState();

    _controller = ypi.YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: const ypi.YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    // Web-specific way to handle "Auto-close on end"
    // _controller.setFullScreenListener((isFullScreen) {
    //   // Logic for fullscreen if needed
    // });

    // If autoPop is enabled, listen to the stream
    if (widget.autoPop) {
      _subscription = _controller.listen((state) {
        if (state.playerState == ypi.PlayerState.ended) {
          if (mounted) Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: youtube_player_iframe handles its own state mostly,
    // so we don't need as many manual listeners as mobile.
    return ypi.YoutubePlayer(controller: _controller, aspectRatio: 16 / 9);
  }
}

/* -------------------------------------------------------------------------- */
/*                        YoutubePlayerFlutter (iOS/Android)                  */
/* -------------------------------------------------------------------------- */

class YoutubePlayerFlutter extends StatefulWidget {
  final String videoId;
  final String videoName;
  final bool autoPop;

  const YoutubePlayerFlutter({
    super.key,
    required this.videoId,
    required this.videoName,
    this.autoPop = false,
  });

  @override
  State<YoutubePlayerFlutter> createState() => _YoutubePlayerFlutterState();
}

class _YoutubePlayerFlutterState extends State<YoutubePlayerFlutter> {
  late ypf.YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = ypf.YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const ypf.YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );

    // Only add the listener if autoPop is enabled
    if (widget.autoPop) {
      _controller.addListener(_onPlayerStateChange);
    }
  }

  void _onPlayerStateChange() {
    if (!mounted) return;
    final value = _controller.value;

    if (value.metaData.duration.inSeconds == 0) return;
    if (value.position.inSeconds < 2) return;

    bool isNearEnd =
        value.position >=
        (value.metaData.duration - const Duration(milliseconds: 500));

    if (value.playerState == ypf.PlayerState.ended ||
        (isNearEnd && value.isPlaying)) {
      _controller.removeListener(_onPlayerStateChange);
      _controller.pause();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ypf.YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      onReady: () => setState(() => _isPlayerReady = true),
    );
  }
}

/*

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

*/
