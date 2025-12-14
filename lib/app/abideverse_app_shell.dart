import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:abideverse/shared/services/locale_services.dart';
import 'package:logging/logging.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/codegen_loader.g.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

final logAbideVerseAppShell = Logger('AbideVerseAppShell');

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
        'abideverse_screen': 'AbideVerseAppShell',
        'abideverse_screen_class': 'AbideVerseAppShellClass',
      },
    );

    String abideverseTitle = LocaleKeys.xlcd.tr();
    String abideverseScriptLabel = LocaleKeys.bibleVerse.tr();
    String abideverseSettingsLabel = LocaleKeys.settings.tr();
    String abideverseBibleChatLabel = LocaleKeys.bibleChat.tr();
    String abideverseAboutLabel = LocaleKeys.about.tr();

    // const maxWidth = 600.0;
    final maxWidth = (MediaQuery.of(context).size.width) * 1.0;
    logAbideVerseAppShell.info(
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
                  if (idx == 2) goRouter.go('/bible-chat');
                  if (idx == 3) goRouter.go('/about');
                  if (idx == 4) goRouter.go('/settings');
                },
                destinations: <NavigationDestination>[
                  // Index 0: JOYS
                  // label: '笑裡藏道',
                  NavigationDestination(
                    label: abideverseTitle,
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                  ),
                  // Index 1: SCRIPTURES
                  // label: '聖經經文',
                  NavigationDestination(
                    label: abideverseScriptLabel,
                    icon: const Icon(Icons.list_outlined),
                    selectedIcon: Icon(Icons.list),
                  ),
                  // Index 2: AI CHAT
                  // label: 'AI聊天',
                  NavigationDestination(
                    label: abideverseBibleChatLabel,
                    icon: const Icon(Icons.chat_bubble_outline),
                    selectedIcon: const Icon(Icons.chat_bubble),
                  ),
                  // Index 3: ABOUT (MOVED)
                  // label: '資源簡介',
                  NavigationDestination(
                    label: abideverseAboutLabel,
                    icon: const Icon(Icons.group_outlined),
                    selectedIcon: const Icon(Icons.group),
                  ),
                  // Index 4: SETTINGS
                  // label: '我的設定',
                  NavigationDestination(
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
