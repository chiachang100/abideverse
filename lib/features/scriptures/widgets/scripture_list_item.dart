// lib/features/scriptures/widgets/scripture_list_item.dart

import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';
import '../models/scripture.dart';

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
          scripture.scriptureName.substring(0, 1),
          style: const TextStyle(fontSize: 20),
        ),
      ),
      onTap: onTap,
    );
  }
}
