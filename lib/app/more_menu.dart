import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/app/router.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/widgets/shared_app_bar.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';

class MoreMenuScreen extends StatefulWidget {
  const MoreMenuScreen({super.key});

  @override
  State<MoreMenuScreen> createState() => _MoreMenuScreenState();
}

class _MoreMenuScreenState extends State<MoreMenuScreen> {
  late String abideverseMoreLabel;
  late String abideverseBibleChatLabel;
  late String abideverseAboutLabel;
  late String abideverseResourcesLabel;
  late String abideverseSettingsLabel;

  @override
  void initState() {
    super.initState();
    abideverseMoreLabel = LocaleKeys.more.tr();
    abideverseBibleChatLabel = LocaleKeys.bibleChat.tr();
    abideverseAboutLabel = LocaleKeys.about.tr();
    abideverseResourcesLabel = LocaleKeys.resources.tr();
    abideverseSettingsLabel = LocaleKeys.settings.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbideAppBar(title: abideverseMoreLabel),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: Text(
              abideverseBibleChatLabel,
            ), // Use your localization keys here
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.bibleChat),
          ),
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: Text(
              abideverseResourcesLabel,
            ), // Use your localization keys here
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.resources),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(
              abideverseSettingsLabel,
            ), // Use your localization keys here
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.settings),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: Text(
              abideverseAboutLabel,
            ), // Use your localization keys here
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}
