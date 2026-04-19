import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/shared/localization/locale_keys.g.dart';

/// Small blue dot indicator
class NewItemDot extends StatelessWidget {
  final bool isNew;
  final double size;

  const NewItemDot({super.key, required this.isNew, this.size = 8});

  @override
  Widget build(BuildContext context) {
    if (!isNew) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
    );
  }
}

/// "NEW" text chip
class NewItemChip extends StatelessWidget {
  final bool isNew;

  const NewItemChip({super.key, required this.isNew});

  @override
  Widget build(BuildContext context) {
    if (!isNew) return const SizedBox.shrink();

    return Tooltip(
      message: LocaleKeys.newFlag.tr(), // Shows text on long-press/hover
      child: Container(
        //padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.fiber_new, color: Colors.white, size: 14),
      ),
    );
  }
}

/// New items banner (shows at top of list)
class NewItemsBanner extends StatelessWidget {
  final int newCount;
  final VoidCallback onView;
  final VoidCallback onDismiss;

  const NewItemsBanner({
    super.key,
    required this.newCount,
    required this.onView,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (newCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.new_releases, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$newCount new ${newCount == 1 ? 'item' : 'items'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: onView,
            child: const Text('VIEW', style: TextStyle(fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
