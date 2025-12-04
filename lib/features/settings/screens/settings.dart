import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:abideverse/widgets/copyright.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/services/db/local_storage_service.dart';
import 'package:abideverse/services/db/joystore_service.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

final abideverselogSettings = Logger('settings');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.firestore});
  final FirebaseFirestore firestore;

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
        'abideverse_screen': '笑裡藏道簡介Screen',
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
                // Navigate to the joys list
                Routes(context).goJoys();
              },
            );
          },
        ),
      ),
      body: SafeArea(child: SettingsContent(firestore: widget.firestore)),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key, required this.firestore});
  final FirebaseFirestore firestore;

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'SettingsContent',
        'abideverse_screen_class': 'SettingsScreenClass',
      },
    );

    return ListView(
      children: const <Widget>[
        LanguageSection(),
        CopyrightSection(),
        SizedBox(height: 10),
      ],
    );
  }
}

class LanguageSection extends StatefulWidget {
  const LanguageSection({super.key});

  @override
  State<LanguageSection> createState() => _LanguageSectionState();
}

class _LanguageSectionState extends State<LanguageSection> {
  String xlcdLanguageSelection = LocaleKeys.settingsLangSetting.tr();

  late bool isEnUs;
  late bool isZhCn;
  late bool isZhTw;

  LocalStorageService storage = LocalStorageService.instance;

  @override
  void initState() {
    super.initState();
    // isEnUs = context.locale == const Locale('en', 'US') ? true : false;
    // isZhCn = context.locale == const Locale('zh', 'CN') ? true : false;
    // isZhTw = context.locale == const Locale('zh', 'TW') ? true : false;
    isEnUs = false;
    isZhCn = false;
    isZhTw = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': 'LanguageSection',
        'abideverse_screen_class': 'SettingsScreenClass',
      },
    );

    switch (context.locale.toString()) {
      case 'en_US':
        isEnUs = true;
      case 'zh_CN':
        isZhCn = true;
      case 'zh_TW':
      default:
        isZhTw = true;
    }

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
                onPressed: () {
                  LocaleConstants.currentLocale = LocaleConstants.zhTW;
                  LocaleConstants.joystoreName = LocaleConstants.joystoreZhTW;
                  storage.saveString(
                    key: 'joysCurrentLocale',
                    value: LocaleConstants.zhTW,
                  );
                  storage.saveString(
                    key: 'joystoreName',
                    value: LocaleConstants.joystoreZhTW,
                  );
                  context.setLocale(const Locale('zh', 'TW'));
                  JoyStoreService.instance
                      .loadFirestoreOrLocal(prod: true)
                      .then((js) => JoyStoreService.instance.joystore = js);
                  setState(() {
                    isEnUs = false;
                    isZhCn = false;
                    isZhTw = true;
                  });

                  FirebaseAnalytics.instance.logEvent(
                    name: 'screen_view',
                    parameters: {
                      'abideverse_screen': 'LanguageSection',
                      'abideverse_screen_class': 'SetLocaleToZhTW',
                    },
                  );
                  abideverselogSettings.info(
                    '[Settings] Notify listeners: Locale=${context.locale.toString()};'
                    ' joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}.',
                  );
                },
                child: Text(LocaleKeys.localeZhTw.tr()),
              ),
              OutlinedButton(
                style: isZhCn
                    ? OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      )
                    : null,
                onPressed: () {
                  LocaleConstants.currentLocale = LocaleConstants.zhCN;
                  LocaleConstants.joystoreName = LocaleConstants.joystoreZhCN;
                  storage.saveString(
                    key: 'joysCurrentLocale',
                    value: LocaleConstants.zhCN,
                  );
                  storage.saveString(
                    key: 'joystoreName',
                    value: LocaleConstants.joystoreZhCN,
                  );
                  context.setLocale(const Locale('zh', 'CN'));
                  JoyStoreService.instance
                      .loadFirestoreOrLocal(prod: true)
                      .then((js) => JoyStoreService.instance.joystore = js);
                  setState(() {
                    isEnUs = false;
                    isZhCn = true;
                    isZhTw = false;
                  });

                  FirebaseAnalytics.instance.logEvent(
                    name: 'screen_view',
                    parameters: {
                      'abideverse_screen': 'LanguageSection',
                      'abideverse_screen_class': 'SetLocaleToZhCN',
                    },
                  );
                  abideverselogSettings.info(
                    '[Settings] Notify listeners: Locale=${context.locale.toString()};'
                    ' joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}.',
                  );
                },
                child: Text(LocaleKeys.localeZhCn.tr()),
              ),
              OutlinedButton(
                style: isEnUs
                    ? OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      )
                    : null,
                onPressed: () {
                  LocaleConstants.currentLocale = LocaleConstants.enUS;
                  LocaleConstants.joystoreName = LocaleConstants.joystoreEnUS;
                  storage.saveString(
                    key: 'joysCurrentLocale',
                    value: LocaleConstants.enUS,
                  );
                  storage.saveString(
                    key: 'joystoreName',
                    value: LocaleConstants.joystoreEnUS,
                  );
                  context.setLocale(const Locale('en', 'US'));
                  JoyStoreService.instance
                      .loadFirestoreOrLocal(prod: true)
                      .then((js) => JoyStoreService.instance.joystore = js);
                  setState(() {
                    isEnUs = true;
                    isZhCn = false;
                    isZhTw = false;
                  });

                  FirebaseAnalytics.instance.logEvent(
                    name: 'screen_view',
                    parameters: {
                      'abideverse_screen': 'LanguageSection',
                      'abideverse_screen_class': 'SetLocaleToEnUs',
                    },
                  );
                  abideverselogSettings.info(
                    '[Settings] Notify listeners: Locale=${context.locale.toString()};'
                    ' joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}.',
                  );
                },
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
