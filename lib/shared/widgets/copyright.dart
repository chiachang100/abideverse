import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class CopyrightSection extends StatelessWidget {
  const CopyrightSection({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'CopyrightSection',
        'abideverse_screen_class': 'AboutScreenClass',
      },
    );

    return Card(
      // color: Colors.yellow[50],
      elevation: 8.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '©️ 2024 joyolord.com Public Domain. MIT/Apache License, Version 2.0.',
          ),
        ],
      ),
    );
  }
}
