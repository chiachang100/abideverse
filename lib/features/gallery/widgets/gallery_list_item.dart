import 'package:flutter/material.dart';
import 'package:abideverse/core/constants/ui_constants.dart';

class GalleryListItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final int index;

  const GalleryListItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Re-using your logic for dynamic avatar colors
    final bgColors = UIConstants.circleAvatarBgColors;
    final avatarColor = bgColors.isNotEmpty
        ? bgColors[index % bgColors.length]
        : Colors.grey;

    // Helper to get the first character (similar to JoyListItem)
    String extractLeadingChar(String text) {
      final regex = RegExp(r'\p{L}', unicode: true);
      final match = regex.firstMatch(text);
      return match != null ? match.group(0)! : '?';
    }

    final leadingChar = extractLeadingChar(title);

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: avatarColor,
            child: Text(
              leadingChar,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _readableTextColor(avatarColor),
              ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),

        Divider(
          height: 1, // The total space occupied by the divider
          thickness: 0.5, // The actual line thickness
          indent: 80, // Starts the line after the CircleAvatar
          endIndent: 20, // Ends the line slightly before the right edge
          color: Theme.of(
            context,
          ).dividerColor.withValues(alpha: 0.5), // Subtle color
        ),
      ],
    );
  }

  Color _readableTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
