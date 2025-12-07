// lib/features/scriptures/widgets/scripture_list_item.dart

import 'package:flutter/material.dart';
import 'package:abideverse/core/constants/ui_constants.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';

class ScriptureListItem extends StatelessWidget {
  final Scripture scripture;
  final int index;
  final VoidCallback? onTap;

  const ScriptureListItem({
    super.key,
    required this.scripture,
    required this.index,
    this.onTap,
  });

  // Auto-select black/white text for best contrast
  Color readableTextColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor =
        UIConstants.circleAvatarBgColors[scripture.articleId %
            UIConstants.circleAvatarBgColors.length];

    return ListTile(
      title: Text(
        '${scripture.title} (${scripture.articleId})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '✞ (${scripture.scriptureName} ${scripture.scriptureChapter}) ${scripture.scriptureVerse}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Text(
          scripture.title.substring(0, 1),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: readableTextColor(avatarColor), // dynamically readable
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
