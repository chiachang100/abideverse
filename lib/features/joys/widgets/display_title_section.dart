import 'package:flutter/material.dart';

class DisplayTitleSection extends StatelessWidget {
  final String photoUrl;
  final String title;
  final int articleId;
  final String scriptureVerse;
  final String scriptureName;

  const DisplayTitleSection({
    super.key,
    required this.photoUrl,
    required this.title,
    required this.articleId,
    required this.scriptureVerse,
    required this.scriptureName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            photoUrl,
            height: MediaQuery.of(context).size.width * 3 / 4,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          Text(
            '$title ($articleId)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '$scriptureVerse ($scriptureName)',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
