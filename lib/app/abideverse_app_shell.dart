import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    String abideverseHomeLabel = LocaleKeys.home.tr();
    String abideverseXlcdTitle = LocaleKeys.xlcd.tr();
    String abideverseScriptLabel = LocaleKeys.scriptures.tr();
    String abideverseTreasureLabel = LocaleKeys.treasures.tr();
    String abideverseBibleChatLabel = LocaleKeys.bibleChat.tr();
    //String abideverseMoreLabel = LocaleKeys.more.tr();
    String abideverseAboutLabel = LocaleKeys.about.tr();
    String abideverseResourcesLabel = LocaleKeys.resources.tr();
    String abideverseSettingsLabel = LocaleKeys.settings.tr();
    String abideverseGalleryLabel = LocaleKeys.gallery.tr();

    // const maxWidth = 600.0;
    final maxWidth = (MediaQuery.of(context).size.width) * 1.0;
    logAbideVerseAppShell.info(
      '[AbideVerseAppShell] Scaffold max width: $maxWidth',
    );

    // The absolute order of your features
    const allPaths = [
      '/', // Home
      '/joys',
      '/scriptures',
      '/treasures',
      '/bible-chat',
      '/gallery',
      '/resources',
      '/settings',
      '/about',
    ];

    final List<NavigationDestination> fullDestinations = [
      NavigationDestination(
        label: abideverseHomeLabel,
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
      ),
      NavigationDestination(
        label: abideverseXlcdTitle,
        icon: const Icon(Icons.record_voice_over_outlined),
        selectedIcon: const Icon(Icons.record_voice_over),
      ),
      NavigationDestination(
        label: abideverseScriptLabel,
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book),
      ),
      NavigationDestination(
        label: abideverseTreasureLabel,
        icon: const Icon(Icons.card_giftcard_outlined),
        selectedIcon: const Icon(Icons.card_giftcard),
      ),
      NavigationDestination(
        label: abideverseBibleChatLabel,
        icon: const Icon(Icons.chat_bubble_outline),
        selectedIcon: const Icon(Icons.chat_bubble),
      ),
      NavigationDestination(
        label: abideverseGalleryLabel,
        icon: const Icon(Icons.collections_outlined),
        selectedIcon: const Icon(Icons.collections),
      ),
      NavigationDestination(
        label: abideverseResourcesLabel,
        icon: const Icon(Icons.library_books_outlined),
        selectedIcon: const Icon(Icons.library_books),
      ),
      NavigationDestination(
        label: abideverseSettingsLabel,
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
      ),
      NavigationDestination(
        label: abideverseAboutLabel,
        icon: const Icon(Icons.info_outline),
        selectedIcon: const Icon(Icons.info),
      ),
    ];

    // 1. Destinations remain 4 items on small screens
    final List<NavigationDestination> currentDestinations = isSmall
        ? fullDestinations.take(4).toList()
        : fullDestinations;

    // 2. The "Safe" Index for the Widget
    // We must provide an index < 4 to avoid the crash.
    // If the actual index is >= 4, we pass 0, but we won't color it as selected.
    final int widgetSelectedIndex = (isSmall && selectedIndex >= 4)
        ? 0
        : selectedIndex;

    // 3. Navigation Logic
    void handleNavigation(int idx) {
      // idx will only ever be 0, 1, 2, or 3 from the BottomBar
      context.go(allPaths[idx]);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Mobile Bottom Bar
      bottomNavigationBar: isSmall
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: NavigationBar(
                  selectedIndex: widgetSelectedIndex, // Use the safe index here
                  onDestinationSelected: handleNavigation,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.7),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: (isSmall && selectedIndex >= 4)
                      ? Colors
                            .transparent // Hide the green pill if we're on a drawer-only page
                      : Colors.green.withValues(alpha: 0.15),

                  destinations: currentDestinations.map((destination) {
                    final int index = currentDestinations.indexOf(destination);

                    // 3. DEFINE isActuallySelected HERE
                    // It is true ONLY if the app's current index matches this specific tab
                    final bool isActuallySelected = selectedIndex == index;

                    final Color adaptiveColor = Theme.of(
                      context,
                    ).colorScheme.onSurface;
                    final IconData iconData = (destination.icon as Icon).icon!;
                    final IconData selectedIconData =
                        (destination.selectedIcon as Icon).icon ?? iconData;

                    return NavigationDestination(
                      label: destination.label,
                      icon: Icon(
                        iconData,
                        color: isActuallySelected
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
