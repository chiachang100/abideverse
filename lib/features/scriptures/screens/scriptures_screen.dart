import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:abideverse/features/scriptures/data/scripture_repository.dart';

import 'package:abideverse/services/db/joystore_service.dart';
import '../widgets/scripture_list.dart';
import 'package:abideverse/services/locale_services.dart';

class ScripturesScreen extends StatefulWidget {
  final String title;
  final ValueChanged<Scripture> onTap;

  const ScripturesScreen({
    required this.onTap,
    // this.title = '聖經經文',
    required this.title,
    super.key,
  });

  @override
  State<ScripturesScreen> createState() => _ScripturesScreenState();
}

class _ScripturesScreenState extends State<ScripturesScreen> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': '聖經經文Screen',
        'abideverse_screen_class': 'ScripturesScreenClass',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.png'),
              onPressed: () {
                GoRouter.of(context).go('/joys/all');
              },
            );
          },
        ),
      ),
      body: ScriptureList(
        scriptures: JoyStoreService.instance.joystore.allScriptures,
        onTap: widget.onTap,
      ),
    );
  }
}
