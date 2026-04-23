import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/app/router.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // We'll use the colorScheme directly to ensure Dark/Light mode compatibility
    final colorScheme = Theme.of(context).colorScheme;

    String abideverseName = LocaleKeys.abideverseName.tr();
    String abideverseHomeLabel = LocaleKeys.home.tr();
    String abideverseJoyTitle = LocaleKeys.joys.tr();
    String abideverseScriptLabel = LocaleKeys.scriptures.tr();
    String abideverseTreasureLabel = LocaleKeys.treasures.tr();
    String abideverseBibleChatLabel = LocaleKeys.bibleChat.tr();
    String abideverseResourcesLabel = LocaleKeys.resources.tr();
    String abideverseSettingsLabel = LocaleKeys.settings.tr();
    String abideverseAboutLabel = LocaleKeys.about.tr();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Controlled Header Height
          SizedBox(
            height: 70, // Even more compact height
            child: DrawerHeader(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  abideverseName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // 2. Uses the theme's 'onSurface' color (Black in Light, White in Dark)
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),

          // 3. Menu Items
          _buildMenuItem(
            context,
            Icons.home_outlined,
            abideverseHomeLabel,
            () => Routes(context).goHome(),
          ),
          _buildMenuItem(
            context,
            Icons.record_voice_over_outlined,
            abideverseJoyTitle,
            () => Routes(context).goJoys(),
          ),
          _buildMenuItem(
            context,
            Icons.menu_book_outlined,
            abideverseScriptLabel,
            () => Routes(context).goScriptures(),
          ),
          _buildMenuItem(
            context,
            Icons.card_giftcard_outlined,
            abideverseTreasureLabel,
            () => Routes(context).goTreasures(),
          ),
          _buildMenuItem(
            context,
            Icons.chat_bubble_outline,
            abideverseBibleChatLabel,
            () => Routes(context).goBibleChat(),
          ),
          _buildMenuItem(
            context,
            Icons.library_books_outlined,
            abideverseResourcesLabel,
            () => Routes(context).goResources(),
          ),
          _buildMenuItem(
            context,
            Icons.settings_outlined,
            abideverseSettingsLabel,
            () => Routes(context).goSettings(),
          ),
          _buildMenuItem(
            context,
            Icons.info_outline,
            abideverseAboutLabel,
            () => Routes(context).goAbout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
      ),
      dense: true,
      onTap: () {
        Navigator.pop(context); // Crucial: Closes drawer before navigating
        onTap();
      },
    );
  }
}
