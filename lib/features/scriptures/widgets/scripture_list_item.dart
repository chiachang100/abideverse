// lib/features/scriptures/widgets/scripture_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/core/constants/ui_constants.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/services/new_item_tracker.dart';
import 'package:abideverse/shared/widgets/new_item_badge.dart';

class ScriptureListItem extends StatefulWidget {
  final Scripture scripture;
  final int index;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback? onTap;
  final bool? initialNewStatus;

  const ScriptureListItem({
    super.key,
    required this.scripture,
    required this.index,
    required this.isLiked,
    required this.onLikeToggle,
    this.onTap,
    this.initialNewStatus,
  });

  @override
  State<ScriptureListItem> createState() => _ScriptureListItemState();
}

class _ScriptureListItemState extends State<ScriptureListItem> {
  bool _showNewBadge = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialNewStatus != null) {
      // Use cached value immediately
      _showNewBadge = widget.initialNewStatus!;
      _isChecking = false;
    } else {
      _checkNewStatus();
    }
  }

  @override
  void didUpdateWidget(ScriptureListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scripture.articleId != widget.scripture.articleId) {
      // Reset state for recycled widget
      if (widget.initialNewStatus != null) {
        _showNewBadge = widget.initialNewStatus!;
        _isChecking = false;
      } else {
        _showNewBadge = false;
        _isChecking = true;
        _checkNewStatus();
      }
    } else if (oldWidget.initialNewStatus != widget.initialNewStatus) {
      // Update if initialNewStatus changed
      _showNewBadge = widget.initialNewStatus ?? false;
    }
  }

  void _checkNewStatus() async {
    try {
      final isNew = await NewItemTracker().isItemNew(
        FeatureType.scriptures,
        widget.scripture.articleId,
        widget.scripture.isNew,
      );
      if (mounted) {
        setState(() {
          _showNewBadge = isNew;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking new status: $e');
      }

      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _handleTap() async {
    if (_showNewBadge) {
      await NewItemTracker().markItemAsRead(
        FeatureType.scriptures,
        widget.scripture.articleId,
      );
      if (mounted) {
        setState(() {
          _showNewBadge = false;
        });
      }
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Avoid repeated list lookups + modulo operations.
    final bgColors = UIConstants.circleAvatarBgColors;
    final avatarColor = bgColors.isNotEmpty
        ? bgColors[widget.scripture.articleId % bgColors.length]
        : Colors.grey;

    // Prevents crash if Scripture Name is empty (rare but safety first).
    final safeTitle = (widget.scripture.title.isNotEmpty)
        ? widget.scripture.title
        : 'Untitled';

    // Prevents crash if Scripture Name is empty (rare but safety first).
    final safeScriptureName = (widget.scripture.scriptureName.isNotEmpty)
        ? widget.scripture.scriptureName
        : 'Untitled';

    // Precompute subtitle efficiently (no string concatenation in Text widget).
    final subtitleText =
        '✞ ${widget.scripture.scriptureVerse} (${widget.scripture.scriptureName} ${widget.scripture.scriptureChapter})';

    String extractLeadingChar(String text) {
      // Enable Unicode mode
      final regex = RegExp(r'\p{L}', unicode: true);

      final match = regex.firstMatch(text);
      return match != null ? match.group(0)! : '?';
    }

    final leadingChar = extractLeadingChar(safeScriptureName);

    // Show loading state briefly if needed
    if (_isChecking) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: const SizedBox.shrink(),
        ),
        title: Text(safeTitle),
      );
    }

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none, // Allows badge to overflow
        children: [
          CircleAvatar(
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
          if (_showNewBadge)
            Positioned(top: -4, right: -4, child: NewItemDot(isNew: true)),
        ],
      ),
      title: Text(
        '${widget.scripture.articleId}. $safeTitle',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: _handleTap,
      onLongPress: () => _showQR(context, widget.scripture),
      trailing: // Check Button
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showNewBadge)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: NewItemChip(isNew: true),
            ),

          IconButton(
            icon: Icon(
              widget.isLiked
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.isLiked ? Colors.green : Colors.grey[400],
            ),
            onPressed: widget.onLikeToggle,
          ),
        ],
      ),
    );
  }

  /// Auto-selects black or white text for the best contrast.
  Color readableTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void _showQR(BuildContext context, Scripture scripture) {
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
                scripture.title,
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
                          'https://abideverse.web.app/scriptures/scripture/${scripture.articleId}',
                      size: qrSize, // Dynamic size
                      gapless: true,
                      embeddedImage: const AssetImage(
                        'assets/logos/abideverse_splash_logo.webp',
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
}
