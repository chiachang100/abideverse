import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';
import 'package:easy_localization/easy_localization.dart';
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
    // 1. Define a robust breakpoint for "Small" (Mobile-style)
    final double width = MediaQuery.of(context).size.width;
    //final bool isSmall = Breakpoints.small.isActive(context);
    final bool isSmall = width < 700;

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

    // 2. Define the Navigation Logic helper
    void handleNavigation(int idx) {
      if (isSmall && idx == 4) {
        context.go('/more');
      } else {
        // Direct navigation logic
        context.go(allPaths[idx]);
      }
    }

    // 3. Fix the Selected Index
    // If we are on mobile and the user is on 'About' (4) or 'Settings' (5),
    // we highlight the 'More' tab (index 4).
    int displayIndex = selectedIndex;
    if (isSmall && selectedIndex >= 4) {
      displayIndex = 4;
    }

  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    // Mobile Bottom Bar
    bottomNavigationBar: isSmall 
      ? NavigationBar(
          selectedIndex: displayIndex,
          onDestinationSelected: handleNavigation,
          destinations: currentDestinations,

          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          height: 70,

          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: Colors.green.withValues(alpha: 0.15), // Light green highlight
        ) 
      : null,
    
    // THE FIX: Use a Row that starts at the absolute left (start)
    body: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures full height
      children: [
        if (!isSmall)
          // The Navigation Rail stays pinned to the left
          NavigationRail(
            extended: width > 1100, // Only extend on very large screens
            selectedIndex: selectedIndex,
            onDestinationSelected: (idx) => context.go(allPaths[idx]),
            backgroundColor: Colors.white,
            // Standard 2026 color syntax
            indicatorColor: Colors.green.withValues(alpha: 0.2),
            labelType: width > 1100 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            unselectedLabelTextStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            selectedLabelTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            unselectedIconTheme: const IconThemeData(color: Colors.black54),
            selectedIconTheme: const IconThemeData(color: Colors.green),
            destinations: fullDestinations.map((d) => NavigationRailDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: Text(d.label),
            )).toList(),
          ),

        // THE FIX: Vertical Divider to create a visual "wall" between menu and content
        if (!isSmall) const VerticalDivider(thickness: 1, width: 1),

        // THE FIX: Expanded forces the content to stay inside the remaining screen space
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            // Ensure child doesn't have its own 'Center' or 'SizedBox' fighting this
            child: child, 
          ),
        ),
      ],
    ),
  );


    // return AdaptiveScaffold(
    //   transitionDuration: Duration.zero,
    //   selectedIndex: displayIndex,
    //   destinations: currentDestinations,
    //   body: (_) => child,
    //   onSelectedIndexChange: (idx) {
    //     if (isSmall && idx == 4) {
    //       // Mobile "More" click: Go to the hub
    //       context.go('/more');
    //     } else {
    //       // Direct navigation for everything else
    //       context.go(allPaths[idx]);
    //     }
    //   },
    // );

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
