// lib/features/joys/widgets/joy_list.dart

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/features/joys/widgets/joy_list_item.dart';

class JoyList extends StatelessWidget {
  final List<Joy> joys;
  final bool isRanked;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final ValueChanged<Joy>? onTap;

  const JoyList({
    super.key,
    required this.joys,
    this.isRanked = false,
    required this.isLiked,
    required this.onLikeToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'JoyListScreen',
        'abideverse_screen_class': 'JoyListClass',
      },
    );

    return ListView.builder(
      itemCount: joys.length,
      itemBuilder: (context, index) {
        final j = joys[index];
        return JoyListItem(
          joy: j,
          index: index,
          isRanked: isRanked,
          isLiked: isLiked,
          onLikeToggle: onLikeToggle,
          onTap: onTap != null ? () => onTap!(j) : null,
        );
      },
    );
  }
}
