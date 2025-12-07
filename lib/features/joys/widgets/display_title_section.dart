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

          Center(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
              child: Image.asset(
                joy.photoUrl,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
