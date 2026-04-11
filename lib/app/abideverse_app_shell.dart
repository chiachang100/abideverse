import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
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
    final bool isSmall = Breakpoints.small.isActive(context);
    final currentLocale = context.locale;

    final goRouter = GoRouter.of(context);

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'AbideVerseAppShell',
        'abideverse_screen_class': 'AbideVerseAppShellClass',
      },
    );

    String abideverseXlcdTitle = LocaleKeys.xlcd.tr();
    String abideverseScriptLabel = LocaleKeys.bibleVerse.tr();
    String abideverseTreasureLabel = LocaleKeys.treasures.tr();
    String abideverseBibleChatLabel = LocaleKeys.bibleChat.tr();
    String abideverseMoreLabel = LocaleKeys.more.tr();
    String abideverseAboutLabel = LocaleKeys.about.tr();
    String abideverseSettingsLabel = LocaleKeys.settings.tr();

    // const maxWidth = 600.0;
    final maxWidth = (MediaQuery.of(context).size.width) * 1.0;
    logAbideVerseAppShell.info(
      '[AbideVerseAppShell] Scaffold max width: $maxWidth',
    );

    // The absolute order of your features
    const allPaths = [
      '/joys',
      '/scriptures',
      '/treasures',
      '/bible-chat',
      '/about',
      '/settings',
    ];

    final List<NavigationDestination> fullDestinations = [
      NavigationDestination(
        label: abideverseXlcdTitle,
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
      ),
      NavigationDestination(
        label: abideverseScriptLabel,
        icon: const Icon(Icons.record_voice_over_outlined),
        selectedIcon: const Icon(Icons.record_voice_over),
      ),
      NavigationDestination(
        label: abideverseTreasureLabel,
        icon: const Icon(Icons.my_library_books_outlined),
        selectedIcon: const Icon(Icons.my_library_books),
      ),
      NavigationDestination(
        label: abideverseBibleChatLabel,
        icon: const Icon(Icons.chat_bubble_outline),
        selectedIcon: const Icon(Icons.chat_bubble),
      ),
      NavigationDestination(
        label: abideverseAboutLabel,
        icon: const Icon(Icons.group_outlined),
        selectedIcon: const Icon(Icons.group),
      ),
      NavigationDestination(
        label: abideverseSettingsLabel,
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
      ),
    ];
    // 1. Determine which destinations to show
    final List<NavigationDestination> currentDestinations = isSmall
        ? [
            ...fullDestinations.take(4), // First 4 items
            NavigationDestination(
              label: abideverseMoreLabel,
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
            ),
          ]
        : fullDestinations;

    // 2. Fix the Selected Index
    // If we are on mobile and the user is on 'About' (4) or 'Settings' (5),
    // we highlight the 'More' tab (index 4).
    int displayIndex = selectedIndex;
    if (isSmall && selectedIndex >= 4) {
      displayIndex = 4;
    }

    return AdaptiveScaffold(
      transitionDuration: Duration.zero,
      selectedIndex: displayIndex,
      destinations: currentDestinations,
      body: (_) => child,
      onSelectedIndexChange: (idx) {
        if (isSmall && idx == 4) {
          // Mobile "More" click: Go to the hub
          context.go('/more');
        } else {
          // Direct navigation for everything else
          context.go(allPaths[idx]);
        }
      },
    );

    // return Scaffold(
    //   body: SafeArea(
    //     child: Padding(
    //       padding: const EdgeInsets.only(bottom: 12.0),
    //       child: Center(
    //         child: SizedBox(
    //           width: maxWidth,
    //           child: AdaptiveScaffold(
    //             //transitionDuration: Durations.short1,
    //             transitionDuration: Duration.zero,
    //             selectedIndex: selectedIndex,
    //             body: (_) => child,
    //             onSelectedIndexChange: (idx) {
    //               if (idx == 0) goRouter.go('/joys');
    //               if (idx == 1) goRouter.go('/scriptures');
    //               if (idx == 2) goRouter.go('/treasures');
    //               if (idx == 3) goRouter.go('/bible-chat');
    //               if (idx == 4) goRouter.go('/about');
    //               if (idx == 5) goRouter.go('/settings');
    //             },
    //             destinations: <NavigationDestination>[
    //               // Index 0: JOYS
    //               // label: '笑裡藏道',
    //               NavigationDestination(
    //                 label: abideverseXlcdTitle,
    //                 icon: const Icon(Icons.home_outlined),
    //                 selectedIcon: const Icon(Icons.home),
    //               ),
    //               // Index 1: SCRIPTURES
    //               // label: '聖經經文',
    //               NavigationDestination(
    //                 label: abideverseScriptLabel,
    //                 icon: const Icon(Icons.record_voice_over_outlined),
    //                 selectedIcon: Icon(Icons.record_voice_over),
    //               ),
    //               // Index 2: TREASURES
    //               // label: '金玉良言',
    //               NavigationDestination(
    //                 label: abideverseTreasureLabel,
    //                 icon: const Icon(Icons.my_library_books_outlined),
    //                 selectedIcon: Icon(Icons.my_library_books),
    //               ),
    //               // Index 3: AI CHAT
    //               // label: 'AI聊天',
    //               NavigationDestination(
    //                 label: abideverseBibleChatLabel,
    //                 icon: const Icon(Icons.chat_bubble_outline),
    //                 selectedIcon: const Icon(Icons.chat_bubble),
    //               ),
    //               // Index 4: ABOUT (MOVED)
    //               // label: '資源簡介',
    //               NavigationDestination(
    //                 label: abideverseAboutLabel,
    //                 icon: const Icon(Icons.group_outlined),
    //                 selectedIcon: const Icon(Icons.group),
    //               ),
    //               // Index 5: SETTINGS
    //               // label: '我的設定',
    //               NavigationDestination(
    //                 label: abideverseSettingsLabel,
    //                 icon: const Icon(Icons.settings_outlined),
    //                 selectedIcon: const Icon(Icons.settings),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
