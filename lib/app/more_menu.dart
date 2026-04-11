import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/app/router.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

class MoreMenuScreen extends StatefulWidget {
  const MoreMenuScreen({super.key});

  @override
  State<MoreMenuScreen> createState() => _MoreMenuScreenState();
}

class _MoreMenuScreenState extends State<MoreMenuScreen> {
  late String abideverseMoreLabel;
  late String abideverseAboutLabel;
  late String abideverseSettingsLabel;

  @override
  void initState() {
    super.initState();
    abideverseMoreLabel = LocaleKeys.more.tr();
    abideverseAboutLabel = LocaleKeys.about.tr();
    abideverseSettingsLabel = LocaleKeys.settings.tr();
  }

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
