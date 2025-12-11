import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/shared/widgets/copyright.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/services/db/local_storage_service.dart';
import 'package:abideverse/core/config/app_config.dart';

final logSettings = Logger('settings');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.firestore,
    required this.joyRepository,
  });

  final FirebaseFirestore firestore;
  final JoyRepository joyRepository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'SettingsScreen',
        'abideverse_screen_class': 'SettingsScreenClass',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings.tr()),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.png'),
              onPressed: () {
                Routes(context).goJoys();
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            LanguageSection(joyRepository: widget.joyRepository),
            const CopyrightSection(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class LanguageSection extends StatefulWidget {
  const LanguageSection({super.key, required this.joyRepository});

  final JoyRepository joyRepository;

  @override
  State<LanguageSection> createState() => _LanguageSectionState();
}

class _LanguageSectionState extends State<LanguageSection> {
  late bool isEnUs;
  late bool isZhCn;
  late bool isZhTw;

  final LocalStorageService storage = LocalStorageService.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = context.locale;
    isEnUs = locale == const Locale('en', 'US');
    isZhCn = locale == const Locale('zh', 'CN');
    isZhTw = locale == const Locale('zh', 'TW');
  }

  Future<void> _setLocale(
    String localeCode,
    String joystoreName,
    Locale locale,
  ) async {
    LocaleConstants.currentLocale = localeCode;
    LocaleConstants.joystoreName = joystoreName;
    bool forceReload = true;

    await storage.saveString(key: 'joysCurrentLocale', value: localeCode);
    await storage.saveString(key: 'joystoreName', value: joystoreName);

    await context.setLocale(locale);

    await widget.joyRepository.getJoys(
      order: SortOrder.asc,
      forceReload: forceReload,
    );

    setState(() {
      isEnUs = locale == const Locale('en', 'US');
      isZhCn = locale == const Locale('zh', 'CN');
      isZhTw = locale == const Locale('zh', 'TW');
    });

    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'LanguageSection',
        'abideverse_screen_class':
            'SetLocaleTo${localeCode.replaceAll('-', '')}',
      },
    );

    logSettings.info(
      '[Settings] Locale set to ${locale.toString()}; '
      'joysCurrentLocale=${LocaleConstants.currentLocale}; '
      'joystoreName=${LocaleConstants.joystoreName} '
      'forceReload=$forceReload.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  "assets/logos/abideverse_splash_logo.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocaleKeys.settingsLangSetting.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.settingsLangSettingsSubtitle.tr(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          OverflowBar(
            spacing: 10,
            overflowSpacing: 20,
            alignment: MainAxisAlignment.center,
            overflowAlignment: OverflowBarAlignment.center,
            children: <Widget>[
              OutlinedButton(
                style: isZhTw
                    ? OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      )
                    : null,
                onPressed: () => _setLocale(
                  LocaleConstants.zhTW,
                  LocaleConstants.joystoreZhTW,
                  const Locale('zh', 'TW'),
                ),
                child: Text(LocaleKeys.localeZhTw.tr()),
              ),
              OutlinedButton(
                style: isZhCn
                    ? OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      )
                    : null,
                onPressed: () => _setLocale(
                  LocaleConstants.zhCN,
                  LocaleConstants.joystoreZhCN,
                  const Locale('zh', 'CN'),
                ),
                child: Text(LocaleKeys.localeZhCn.tr()),
              ),
              // EN-US — ENABLED ONLY WHEN FLAG IS TRUE
              if (AppConfig.enableEnglishButton)
                OutlinedButton(
                  style: isEnUs
                      ? OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        )
                      : null,
                  onPressed: () => _setLocale(
                    LocaleConstants.enUS,
                    LocaleConstants.joystoreEnUS,
                    const Locale('en', 'US'),
                  ),
                  child: Text(LocaleKeys.localeEnUs.tr()),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
