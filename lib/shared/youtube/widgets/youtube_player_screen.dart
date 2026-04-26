import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;
  const YoutubePlayerScreen({required this.videoId, super.key});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_onPlayerStateChange);
    ;
  }

  void _onPlayerStateChange() {
    if (!mounted) return;

    final value = _controller.value;

    // 1. SAFETY CHECK: If metadata hasn't loaded, the duration might be 0.
    // We don't want to close the player if the video hasn't even started.
    if (value.metaData.duration.inSeconds == 0) return;

    // 2. ONLY check for the end if the video has played for at least a few seconds
    if (value.position.inSeconds < 2) return;

    // 3. DEFINE THE END: Check if we are within the last 500ms
    bool isNearEnd =
        value.position >=
        (value.metaData.duration - const Duration(milliseconds: 500));
    bool isEnded = value.playerState == PlayerState.ended;

    if (isEnded || (isNearEnd && value.isPlaying)) {
      // Stop the listener immediately so it doesn't trigger twice
      _controller.removeListener(_onPlayerStateChange);

      _controller.pause();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are in Dark Mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Force the controller to stop the moment the user leaves
          _controller.pause();
        }
      },

      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          onEnded: (metadata) {
            // Force the controller to recognize the video has stopped
            _controller.pause();
            setState(() => _isPlayerReady = true);
            debugPrint('Video ended, stopping the "ghost" spinner.');
          },
          onReady: () {
            setState(() {
              _isPlayerReady = true;
            });

            debugPrint('Player is ready.');
          },
        ),
        builder: (context, player) {
          return Scaffold(
            // The Scaffold background will now be white in light mode / grey-black in dark mode
            appBar: AppBar(
              // Removing hardcoded black so it uses the theme's AppBar color
              title: Text(
                'AbideVerse Player',
                // Uses the theme's text color automatically
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              // Ensure the automatic back button uses the theme's icon color
              iconTheme: IconThemeData(
                color: Theme.of(context).iconTheme.color,
              ),
              elevation: 0,
            ),
            body: Column(
              children: [
                // We wrap the player in a black container so the video "letterboxing"
                // remains cinematic regardless of the app theme.
                Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      player,
                      if (!_isPlayerReady)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                    ],
                  ),
                ),

                // You can add video details here later
                if (!isDarkMode) const Divider(),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }
}
