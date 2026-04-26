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

    // KEY FIX: Instead of waiting for PlayerState.ended, we catch it
    // just BEFORE it ends (e.g., when there is 0.5 seconds left)
    // OR as soon as it hits the ended state but BEFORE the IFrame reloads.

    bool isNearEnd =
        value.position >=
        (value.metaData.duration - const Duration(milliseconds: 500));
    bool isEnded = value.playerState == PlayerState.ended;

    if (isEnded || (isNearEnd && value.isPlaying)) {
      // 1. SILENCE the player immediately to stop the native thread
      _controller.pause();

      // 2. Hide the player visually (optional but prevents the "flash")
      setState(() => _isPlayerReady = false);

      // 3. Give iOS a clear window to breathe
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          // 4. Use a "Clean Pop"
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
