import 'package:flutter/material.dart';
import 'package:abideverse/features/joys/models/joy.dart';

class DisplayTitleSection extends StatelessWidget {
  final Joy joy;

  const DisplayTitleSection({super.key, required this.joy});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${joy.scriptureName} ${joy.scriptureChapter}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          /// Verse text
          Text(
            '✞ ${joy.scriptureVerse} (${joy.scriptureName} ${joy.scriptureChapter})',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 16),

          // Image.asset(
          //   joy.photoUrl,
          //   height: MediaQuery.of(context).size.width * 3 / 4,
          //   width: double.infinity,
          //   fit: BoxFit.contain,
          // ),

          /// Image with nice clipping + aspect ratio
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(
                joy.photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
