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
import 'package:abideverse/shared/services/new_item_tracker.dart';

import 'package:abideverse/shared/widgets/shared_app_bar.dart';
import 'package:abideverse/shared/widgets/shared_app_drawer.dart';

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
  int _secretTapCount = 0; // Track taps
  bool _showAdminSection = false; // Control visibility

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

  void _handleSecretTap() {
    setState(() {
      _secretTapCount++;
      debugPrint("_handleSecretTap: Tapped $_secretTapCount times.");

      if (_secretTapCount >= 7) {
        // 7 taps is a safe standard
        _showAdminSection = !_showAdminSection;
        _secretTapCount = 0;

        debugPrint("_handleSecretTap: Tapped 7 or more times.");

        // Optional: Provide subtle haptic feedback so you know it worked
        // HapticFeedback.lightImpact();
      }
    });

    // Reset the count if the user stops tapping for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _secretTapCount = 0;
      debugPrint(
        "Reset the count due to the user stops tapping for 2 seconds.",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbideAppBar(title: LocaleKeys.settings.tr()),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          children: [
            LanguageSection(joyRepository: widget.joyRepository),
            Divider(),

            // Step 2: Conditional Rendering
            if (_showAdminSection) ...[
              const ResetPrefsSection(),
              const Divider(),
            ],

            // Step 3: The Secret Trigger
            GestureDetector(
              onTap: _handleSecretTap,
              child: const CopyrightSection(),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

//
// Language Selection Section
//
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
      order: SortOrder.desc,
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

    // Turn on Global AppConfig.forceReloadRepo
    AppConfig.forceReloadRepo = forceReload;

    logSettings.info(
      '[Settings] Locale set to ${locale.toLanguageTag()}; '
      'joysCurrentLocale=${LocaleConstants.currentLocale}; '
      'joystoreName=${LocaleConstants.joystoreName} '
      'AppConfig.forceReloadRepo=${AppConfig.forceReloadRepo}.',
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                height: 150,
                width: 100,
                child: Image.asset(
                  "assets/logos/abideverse_splash_logo.webp",
                  fit: BoxFit.contain,
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

//
// Reset Shared Preferences Section
//
class ResetPrefsSection extends StatefulWidget {
  const ResetPrefsSection({super.key});

  @override
  State<ResetPrefsSection> createState() => _ResetPrefsSectionState();
}

class _ResetPrefsSectionState extends State<ResetPrefsSection> {
  @override
  Widget build(BuildContext context) {
    return _buildDataManagementCard(context);
  }

  Widget _buildDataManagementCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              LocaleKeys.dataMgmt.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias, // Ensures splash stays inside corners
            child: Column(
              children: [
                _buildResetTile(
                  context,
                  title:
                      '${LocaleKeys.resetText.tr()} ${LocaleKeys.newFlag.tr()} [joys]',
                  featureType: FeatureType.joys,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildResetTile(
                  context,
                  title:
                      '${LocaleKeys.resetText.tr()} ${LocaleKeys.newFlag.tr()} [scriptures]',
                  featureType: FeatureType.scriptures,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildResetTile(
                  context,
                  title:
                      '${LocaleKeys.resetText.tr()} ${LocaleKeys.newFlag.tr()} [treasures]',
                  featureType: FeatureType.treasures,
                ),
                Container(
                  color: Colors.red.withValues(
                    alpha: 0.05,
                  ), // Subtle hint of danger
                  child: ListTile(
                    title: Text(
                      '${LocaleKeys.resetText.tr()} ${LocaleKeys.newFlag.tr()} [all features]',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: const Icon(Icons.delete_sweep, color: Colors.red),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.red,
                    ),
                    onTap: () => _confirmReset(context, isAll: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetTile(
    BuildContext context, {
    required String title,
    required FeatureType featureType,
  }) {
    return ListTile(
      title: Text(title),
      leading: const Icon(Icons.refresh),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _confirmReset(context, feature: featureType),
    );
  }

  Future<void> _confirmReset(
    BuildContext context, {
    FeatureType? feature,
    bool isAll = false,
  }) async {
    final String featureName = isAll ? 'all features' : feature!.name;

    logger.info('User initiated reset for $featureName');

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${LocaleKeys.resetText.tr()} [$featureName]?'),
        content: Text('[$featureName]: ${LocaleKeys.resetConfirmMsg.tr()}}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(LocaleKeys.resetText.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final tracker = NewItemTracker();
      if (isAll) {
        await tracker.clearAllReadItems();
      } else {
        await tracker.resetFeature(feature!);
      }

      logger.info(
        'Reset complete: all items of $featureName are now marked as new.',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '[$featureName]: ${LocaleKeys.resetCompleteMsg.tr()}',
            ),
          ),
        );
      }
    }
  }
}
