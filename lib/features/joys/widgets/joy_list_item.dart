import 'package:flutter/material.dart';
import 'package:abideverse/core/constants/ui_constants.dart';
import 'package:abideverse/features/joys/models/joy.dart';

class JoyListItem extends StatelessWidget {
  final Joy joy;
  final int index;
  final bool isRanked;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  //final void Function(Joy joy) onTap;
  final VoidCallback? onTap;

  const JoyListItem({
    super.key,
    required this.joy,
    required this.index,
    this.isRanked = false,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onTap,
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
        ? bgColors[joy.articleId % bgColors.length]
        : Colors.grey;

    // Prevents crash if Scripture Name is empty (rare but safety first).
    final safeTitle = (joy.title.isNotEmpty) ? joy.title : 'Untitled';

    // Precompute subtitle efficiently (no string concatenation in Text widget).
    final subtitleText =
        '✞ ${joy.scriptureVerse} (${joy.scriptureName} ${joy.scriptureChapter})';

    // Precompute subtitle efficiently (no string concatenation in Text widget).
    final laughText = '•ᴗ• ${joy.laugh}';

    String extractLeadingChar(String text) {
      // Enable Unicode mode
      final regex = RegExp(r'\p{L}', unicode: true);

      final match = regex.firstMatch(text);
      return match != null ? match.group(0)! : '?';
    }

    final leadingChar = extractLeadingChar(safeTitle);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Text(
          leadingChar,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: readableTextColor(avatarColor), // dynamically readable
          ),
        ),
      ),
      title: Text(
        '${joy.articleId}. $safeTitle',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(laughText, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      //onTap: () => onTap(joy),
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : null,
        ),
        onPressed: onLikeToggle,
      ),
    );
  }
}
