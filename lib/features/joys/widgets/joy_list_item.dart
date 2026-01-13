import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/core/constants/ui_constants.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class JoyListItem extends StatelessWidget {
  final Joy joy;
  final int index;
  final bool isRanked;
  final bool isLiked;
  final VoidCallback onLikeToggle;
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

  void _showQR(BuildContext context, Joy joy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to expand if needed
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Very important for bottom sheets
            children: [
              // Grab handle for visual cue
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                joy.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Fix: Use LayoutBuilder to ensure the QR fits any screen size
              LayoutBuilder(
                builder: (context, constraints) {
                  // Take the smaller of: 200 or 50% of screen width
                  double qrSize = constraints.maxWidth * 0.5;
                  if (qrSize > 200) qrSize = 200;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data:
                          'https://abideverse.web.app/joys/joy/${joy.articleId}',
                      size: qrSize, // Dynamic size
                      gapless: true,
                      embeddedImage: const AssetImage(
                        'assets/logos/abideverse_splash_logo.png',
                      ),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                LocaleKeys.scanToRead.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
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
      onLongPress: () => _showQR(context, joy),
      trailing: // Favorite Button
      IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : null,
        ),
        onPressed: onLikeToggle,
      ),
    );
  }
}
