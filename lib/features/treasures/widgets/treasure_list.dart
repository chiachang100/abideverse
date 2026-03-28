// lib/features/treasures/widgets/treasure_list.dart
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/features/treasures/models/treasure.dart';
import 'package:abideverse/features/treasures/widgets/treasure_list_item.dart';

class TreasureList extends StatelessWidget {
  final List<Treasure> treasures;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final ValueChanged<Treasure>? onTap;

  const TreasureList({
    super.key,
    required this.treasures,
    required this.isLiked,
    required this.onLikeToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'TreasureListScreen',
        'abideverse_screen_class': 'TreasureListClass',
      },
    );

    return ListView.builder(
      itemCount: treasures.length,
      itemBuilder: (context, index) {
        final s = treasures[index];
        return TreasureListItem(
          treasure: s,
          index: index,
          isLiked: isLiked,
          onLikeToggle: onLikeToggle,
          onTap: onTap != null ? () => onTap!(s) : null,
        );
      },
    );
  }
}
