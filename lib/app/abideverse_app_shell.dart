import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/shared/services/locale_services.dart';
import 'package:logging/logging.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/codegen_loader.g.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

final abideverseLogAbideVerseAppShell = Logger('AbideVerseAppShell');

class AbideVerseAppShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const AbideVerseAppShell({
    required this.child,
    required this.selectedIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter.of(context);

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'AdaptiveScaffoldScreen',
        'abideverse_screen_class': 'AbideVerseAppShellClass',
      },
    );

    String abideverseTitle = LocaleKeys.xlcd.tr();
    String abideverseScriptLabel = LocaleKeys.bibleVerse.tr();
    String abideverseSettingsLabel = LocaleKeys.settings.tr();
    String abideverseAboutLabel = LocaleKeys.about.tr();

    // const maxWidth = 600.0;
    final maxWidth = (MediaQuery.of(context).size.width) * 1.0;
    abideverseLogAbideVerseAppShell.info(
      '[AbideVerseAppShell] Scaffold max width: $maxWidth',
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Center(
            child: SizedBox(
              width: maxWidth,
              child: AdaptiveScaffold(
                //transitionDuration: Durations.short1,
                transitionDuration: Duration.zero,
                selectedIndex: selectedIndex,
                body: (_) => child,
                onSelectedIndexChange: (idx) {
                  if (idx == 0) goRouter.go('/joys');
                  if (idx == 1) goRouter.go('/scriptures');
                  if (idx == 2) goRouter.go('/about');
                  if (idx == 3) goRouter.go('/settings');
                },
                destinations: <NavigationDestination>[
                  NavigationDestination(
                    // label: '笑裡藏道',
                    label: abideverseTitle,
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                  ),
                  NavigationDestination(
                    // label: '聖經經文',
                    label: abideverseScriptLabel,
                    icon: const Icon(Icons.list_outlined),
                    selectedIcon: Icon(Icons.list),
                  ),
                  NavigationDestination(
                    // label: '資源簡介',
                    label: abideverseAboutLabel,
                    icon: const Icon(Icons.group_outlined),
                    selectedIcon: const Icon(Icons.group),
                  ),
                  NavigationDestination(
                    // label: '我的設定',
                    label: abideverseSettingsLabel,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
