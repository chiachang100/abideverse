// lib/features/scriptures/widgets/scripture_list.dart
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/features/scriptures/models/scripture.dart';
import 'package:abideverse/features/scriptures/widgets/scripture_list_item.dart';

class ScriptureList extends StatelessWidget {
  final List<Scripture> scriptures;
  final ValueChanged<Scripture>? onTap;

  const ScriptureList({super.key, required this.scriptures, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ScriptureListScreen',
        'abideverse_screen_class': 'ScriptureListClass',
      },
    );

    return ListView.builder(
      itemCount: scriptures.length,
      itemBuilder: (context, index) {
        final s = scriptures[index];
        return ScriptureListItem(
          scripture: s,
          index: index,
          onTap: onTap != null ? () => onTap!(s) : null,
        );
      },
    );
  }
}
