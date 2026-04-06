import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/app/router.dart';
import 'package:abideverse/shared/localization/codegen_loader.g.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  static String abideverseMoreLabel = LocaleKeys.more.tr();
  static String abideverseAboutLabel = LocaleKeys.about.tr();
  static String abideverseSettingsLabel = LocaleKeys.settings.tr();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(abideverseMoreLabel)), // Optional
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text(
              abideverseAboutLabel,
            ), // Use your localization keys here
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.about),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(
              abideverseSettingsLabel,
            ), // Use your localization keys here
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
