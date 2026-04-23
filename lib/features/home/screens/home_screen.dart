import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/features/home/widgets/feature_carousel.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/shared/services/db/local_storage_service.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

import 'package:abideverse/shared/widgets/shared_app_bar.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';

final logHomeScreen = Logger('HomeScreen');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late JoyRepository _joyRepository;
  final LocalStorageService storage = LocalStorageService.instance;
  bool _isChangingLanguage = false;

  // Add a key that changes when language changes to force rebuild
  Key _carouselKey = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _joyRepository = JoyRepository(locale: context.locale.toLanguageTag());
  }

  Future<void> _changeLanguage(
    String localeCode,
    String joystoreName,
    Locale locale,
  ) async {
    if (_isChangingLanguage) return;

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    _isChangingLanguage = true;

    try {
      await storage.saveString(key: 'joysCurrentLocale', value: localeCode);
      await storage.saveString(key: 'joystoreName', value: joystoreName);

      LocaleConstants.currentLocale = localeCode;
      LocaleConstants.joystoreName = joystoreName;

      await context.setLocale(locale);
      await Future.delayed(const Duration(milliseconds: 100));

      _joyRepository = JoyRepository(locale: localeCode);
      await _joyRepository.getJoys(order: SortOrder.desc, forceReload: true);

      AppConfig.forceReloadRepo = true;

      FirebaseAnalytics.instance.logEvent(
        name: 'language_changed',
        parameters: {'from_screen': 'HomeScreen', 'new_locale': localeCode},
      );

      if (mounted) {
        // Force carousel to rebuild with new key
        setState(() {
          _carouselKey = UniqueKey();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to ${locale.toLanguageTag()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      logHomeScreen.severe('[HomeScreen] Error changing language: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isChangingLanguage = false;
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final isEnUs = context.locale == const Locale('en', 'US');
            final isZhCn = context.locale == const Locale('zh', 'CN');
            final isZhTw = context.locale == const Locale('zh', 'TW');

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        LocaleKeys.settingsLangSetting.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton(
                    style: isZhTw
                        ? OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          )
                        : OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                    onPressed: _isChangingLanguage
                        ? null
                        : () => _changeLanguage(
                            LocaleConstants.zhTW,
                            LocaleConstants.joystoreZhTW,
                            const Locale('zh', 'TW'),
                          ),
                    child: Text(LocaleKeys.localeZhTw.tr()),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    style: isZhCn
                        ? OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          )
                        : OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                    onPressed: _isChangingLanguage
                        ? null
                        : () => _changeLanguage(
                            LocaleConstants.zhCN,
                            LocaleConstants.joystoreZhCN,
                            const Locale('zh', 'CN'),
                          ),
                    child: Text(LocaleKeys.localeZhCn.tr()),
                  ),

                  if (AppConfig.enableEnglishButton) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: isEnUs
                          ? OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 50),
                            )
                          : OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                      onPressed: _isChangingLanguage
                          ? null
                          : () => _changeLanguage(
                              LocaleConstants.enUS,
                              LocaleConstants.joystoreEnUS,
                              const Locale('en', 'US'),
                            ),
                      child: Text(LocaleKeys.localeEnUs.tr()),
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(LocaleKeys.cancel.tr()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.abideverseName.tr()),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: LocaleKeys.settingsLangSetting.tr(),
            onPressed: () => _showLanguageBottomSheet(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              // Use key to force rebuild when language changes
              Expanded(child: FeatureCarousel(key: _carouselKey)),
            ],
          ),
        ),
      ),
    );
  }
}
