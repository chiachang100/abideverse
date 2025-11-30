import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/l10n/codegen_loader.g.dart';
import 'package:abideverse/l10n/locale_keys.g.dart';

import '../data/data_index.dart';
import '../widgets/joy_list.dart';

class ScriptureDetailsScreen extends StatelessWidget {
  final Scripture scripture;
  final ValueChanged<Joy> onJoyTapped;

  const ScriptureDetailsScreen({
    super.key,
    required this.scripture,
    required this.onJoyTapped,
  });

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'ScriptureDetailsScreen',
        'abideverse_screen_class': 'ScriptureDetailsScreenClass',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.bibleVerse.tr()),
        // leading: Image.asset('assets/icons/xlcdapp-leading-icon.png'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              '${scripture.title} (${scripture.articleId})',
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          const SizedBox(height: 10.0),
          ScriptureSection(scripture: scripture),
        ],
      ),
    );
  }
}

class ScriptureSection extends StatelessWidget {
  final Scripture scripture;

  const ScriptureSection({super.key, required this.scripture});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: ListTile(
        title: Text(scripture.name, style: const TextStyle(fontSize: 18.0)),
        subtitle: Text('${scripture.verse} (${scripture.name})'),
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor:
              circleAvatarBgColor[(scripture.id % circleAvatarBgColor.length)],
          child: Text(
            scripture.name.substring(0, 1),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
