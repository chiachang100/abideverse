import 'package:flutter/material.dart';
import 'package:abideverse/shared/utils/sound_player.dart';

class DisplayArticleContent extends StatelessWidget {
  final String title;
  final String content;
  final bool addEmoji;

  const DisplayArticleContent({
    super.key,
    required this.title,
    required this.content,
    this.addEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    final soundPlayer = RandomSoundPlayer();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 16)),
            if (addEmoji)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    soundPlayer.playRandomSound();
                  },
                  child: const Text('🤣🤣🤣'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
