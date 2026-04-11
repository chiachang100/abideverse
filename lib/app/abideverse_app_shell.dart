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
            ...fullDestinations.take(3), // First 3 items
            NavigationDestination(
              label: abideverseMoreLabel,
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
            ),
          ]
        : fullDestinations;

    // 2. Define the Navigation Logic helper
    void handleNavigation(int idx) {
      if (isSmall && idx == 3) {
        context.go('/more');
      } else {
        // Direct navigation logic
        context.go(allPaths[idx]);
      }
    }

    // 3. Fix the Selected Index
    // If we are on mobile and the user is on 'Bible Chat' (3), 'About' (4) or 'Settings' (5),
    // we highlight the 'More' tab (index 3).
    int displayIndex = selectedIndex;
    if (isSmall && selectedIndex >= 3) {
      displayIndex = 3;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Mobile Bottom Bar
      bottomNavigationBar: isSmall
          ? Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  // 1. ICON LOGIC: Green when selected, Black54 when not
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Colors.green, size: 28);
                    }
                    return const IconThemeData(color: Colors.black54, size: 24);
                  }),
                  // 2. TEXT LOGIC: Bold Black when selected, Black54 when not
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                    }
                    return const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                selectedIndex: displayIndex,
                onDestinationSelected: handleNavigation,
                destinations: currentDestinations,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 10,
                height: 70,
                indicatorColor: Colors.green.withValues(alpha: 0.15),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
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
              labelType: width > 1100
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              unselectedIconTheme: const IconThemeData(color: Colors.black54),
              selectedIconTheme: const IconThemeData(color: Colors.green),
              destinations: fullDestinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),

          // THE FIX: Vertical Divider to create a visual "wall" between menu and content
          if (!isSmall) const VerticalDivider(thickness: 1, width: 1),

          // THE FIX: Expanded forces the content to stay inside the remaining screen space
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              // Ensure child doesn't have its own 'Center' or 'SizedBox' fighting this
              child: SafeArea(
                top: true, // Protects the clock/notch area
                bottom: false, // NavigationBar handles the bottom
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
