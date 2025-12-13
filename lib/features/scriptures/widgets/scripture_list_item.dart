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

  /// Auto-selects black or white text for the best contrast.
  Color readableTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    // Avoid repeated list lookups + modulo operations.
    final bgColors = UIConstants.circleAvatarBgColors;
    final avatarColor = bgColors.isNotEmpty
        ? bgColors[scripture.articleId % bgColors.length]
        : Colors.grey;

    // Prevents crash if Scripture Name is empty (rare but safety first).
    final safeTitle = (scripture.title.isNotEmpty)
        ? scripture.title
        : 'Untitled';

    // Prevents crash if Scripture Name is empty (rare but safety first).
    final safeScriptureName = (scripture.scriptureName.isNotEmpty)
        ? scripture.scriptureName
        : 'Untitled';

    // Precompute subtitle efficiently (no string concatenation in Text widget).
    final subtitleText =
        '✞ ${scripture.scriptureVerse} (${scripture.scriptureName} ${scripture.scriptureChapter})';

    String extractLeadingChar(String text) {
      // Enable Unicode mode
      final regex = RegExp(r'\p{L}', unicode: true);

      final match = regex.firstMatch(text);
      return match != null ? match.group(0)! : '?';
    }

    final leadingChar = extractLeadingChar(safeScriptureName);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Text(
          leadingChar,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: readableTextColor(avatarColor),
          ),
        ),
      ),
      title: Text(
        '$safeTitle (${scripture.articleId})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
