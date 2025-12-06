import 'package:flutter/material.dart';
import 'package:abideverse/features/joys/models/joy.dart';

class JoyListItem extends StatelessWidget {
  final Joy joy;
  final int index;
  final bool isRanked;
  //final void Function(Joy joy) onTap;
  final VoidCallback? onTap;

  const JoyListItem({
    super.key,
    required this.joy,
    required this.index,
    this.isRanked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
          maxWidth: 64,
          maxHeight: 64,
        ),
        child: Image.asset(joy.photoUrl, fit: BoxFit.cover),
      ),
      title: Text(
        '${joy.title} (${joy.articleId})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✞ (${joy.scriptureName} ${joy.scriptureChapter})${joy.scriptureVerse}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '•ᴗ• ${joy.laugh}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      //onTap: () => onTap(joy),
      onTap: onTap,
    );
  }
}
