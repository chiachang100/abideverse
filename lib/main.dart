import 'dart:io' show Platform;
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:window_size/window_size.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abideverse/core/logging/logging_setup.dart';
import 'package:abideverse/startup/abideverse_root.dart';
import 'package:abideverse/shared/models/locale_info_model.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/services/new_item_tracker.dart';
import 'firebase_options.dart';

final logMain = Logger('main');
final kDefaultLocale = const Locale('zh', 'TW');

class L10n {
  static final allLocales = [
    const Locale('en', 'US'),
    const Locale('zh', 'CN'),
    const Locale('zh', 'TW'),
  ];
}

Future<void> main() async {
  // Logging (non-blocking)
  setupLogging();

  logMain.info('[Main] Logging initialized.');

  // Minimal required init
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await NewItemTracker.init();

  // Preserve native splash until we explicitly remove it in StartupScreen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // System chrome style quickly
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
  );

  // Setup url strategy for web (no blocking)
  usePathUrlStrategy();

  // Setup window (non-blocking call)
  _maybeSetupWindow();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Ensure easy_localization is ready
  await EasyLocalization.ensureInitialized();

  logMain.info('[Main] calling runApp().');

  // Run the app as fast as possible
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: L10n.allLocales,
        path: 'assets/translations',
        fallbackLocale: kDefaultLocale,
        startLocale: kDefaultLocale,
        saveLocale: true,
        child: ChangeNotifierProvider(
          create: (_) => LocaleInfoModel(),
          child: AbideVerseRoot(),
        ),
      ),
    ),
  );
}

/// Desktop window setup helper (kept lightweight)
const double windowWidth = 480;
const double windowHeight = 854;

void _maybeSetupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      setWindowTitle(LocaleKeys.appTitle.tr());
      setWindowMinSize(const Size(windowWidth, windowHeight));
      setWindowMaxSize(const Size(windowWidth, windowHeight));
      getCurrentScreen().then((screen) {
        if (screen == null) return;
        setWindowFrame(
          Rect.fromCenter(
            center: screen.frame.center,
            width: windowWidth,
            height: windowHeight,
          ),
        );
      });
    } catch (_) {
      // ignore window setting errors on platforms where this may fail
    }
  }
}
