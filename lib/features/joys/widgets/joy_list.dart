// lib/features/joys/widgets/joy_list.dart

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/features/joys/models/joy.dart';
import 'package:abideverse/features/joys/widgets/joy_list_item.dart';

class JoyList extends StatelessWidget {
  final List<Joy> joys;
  final ValueChanged<Joy>? onTap;
  final bool isRanked;

  const JoyList({
    super.key,
    required this.joys,
    this.onTap,
    this.isRanked = false,
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
          onTap: onTap != null ? () => onTap!(j) : null,
        );
      },
    );
  }
}
