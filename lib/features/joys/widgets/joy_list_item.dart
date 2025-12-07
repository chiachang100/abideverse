import 'package:flutter/material.dart';
import 'package:abideverse/core/constants/ui_constants.dart';
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

  // Auto-select black/white text for best contrast
  Color readableTextColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    @override
    final avatarColor =
        UIConstants.circleAvatarBgColors[joy.articleId %
            UIConstants.circleAvatarBgColors.length];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Text(
          joy.title.substring(0, 1),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: readableTextColor(avatarColor), // dynamically readable
          ),
        ),
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
