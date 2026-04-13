import 'dart:ui';
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
    String abideverseResourcesLabel = LocaleKeys.resources.tr();
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
      '/resources',
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
        label: abideverseResourcesLabel,
        icon: const Icon(Icons.library_books_outlined),
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
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: NavigationBar(
                  selectedIndex: displayIndex,
                  onDestinationSelected: handleNavigation,
                  // FORCE TRANSPARENCY HERE
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.7),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  indicatorColor: Colors.green.withValues(alpha: 0.15),

                  // MAP DESTINATIONS MANUALLY TO FORCE COLOR
                  destinations: currentDestinations.map((destination) {
                    final int index = currentDestinations.indexOf(destination);
                    final bool isSelected = displayIndex == index;

                    // Get the default text/icon color for the current theme
                    // (White in Dark Mode, Black in Light Mode)
                    final Color adaptiveColor = Theme.of(
                      context,
                    ).colorScheme.onSurface;

                    // 1. Extract the icon data from your list
                    final IconData iconData = (destination.icon as Icon).icon!;
                    final IconData selectedIconData =
                        (destination.selectedIcon as Icon).icon ?? iconData;

                    return NavigationDestination(
                      label: destination.label,
                      icon: Icon(
                        iconData,
                        // FIX: Use adaptiveColor instead of hardcoded Black
                        color: isSelected
                            ? Colors.green
                            : adaptiveColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                      selectedIcon: Icon(
                        selectedIconData,
                        color: Colors.green,
                        size: 28,
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          : null,

      // THE FIX: Use a Row that starts at the absolute left (start)
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures full height
        children: [
          if (!isSmall)
            LayoutBuilder(
              builder: (context, constraint) {
                return SingleChildScrollView(
                  // Constrain the scroll view to the height of the screen
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraint.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      // The Navigation Rail stays pinned to the left
                      child: NavigationRail(
                        extended:
                            width > 1100, // Only extend on very large screens
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (idx) =>
                            context.go(allPaths[idx]),

                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.8),

                        // Standard 2026 color syntax
                        indicatorColor: Colors.green.withValues(alpha: 0.2),
                        labelType: width > 1100
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,

                        unselectedLabelTextStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        selectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),

                        unselectedIconTheme: IconThemeData(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        selectedIconTheme: const IconThemeData(
                          color: Colors.green,
                        ),

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
                    ),
                  ),
                );
              },
            ),

          // THE FIX: Vertical Divider to create a visual "wall" between menu and content
          if (!isSmall)
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),

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
