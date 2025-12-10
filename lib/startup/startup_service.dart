import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:abideverse/shared/services/db/local_storage_service.dart';
import 'package:abideverse/shared/services/firebase/firebase_service.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/firebase_options.dart';
import 'package:abideverse/main.dart' show setupWindow;
import 'package:window_size/window_size.dart';
import 'package:abideverse/shared/services/ai/ai_factory.dart';

class StartupService {
  StartupService._();
  static final instance = StartupService._();

  /// Run all heavy startup tasks. This is intended to be called
  /// AFTER runApp() on a background async path (e.g. from StartupScreen).
  Future<void> run() async {
    // 1) Initialize Firebase and FirebaseService
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseService.instance.app = app;
    FirebaseService.instance.auth = FirebaseAuth.instanceFor(app: app);

    // 2) Firestore settings
    final firestore = FirebaseFirestore.instance;
    firestore.settings = firestore.settings.copyWith(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 3) Locale fixes saved in local storage (keys normalization)
    final storage = LocalStorageService.instance;

    String currentLocale = await storage.getString(
      key: 'joysCurrentLocale',
      defaultValue: LocaleConstants.currentLocale,
    );

    String joystoreName = await storage.getString(
      key: 'joystoreName',
      defaultValue: LocaleConstants.joystoreName,
    );

    // Normalize to zh-TW as your canonical asset naming
    if (currentLocale != LocaleConstants.zhTW) {
      await storage.saveString(
        key: 'joysCurrentLocale',
        value: LocaleConstants.zhTW,
      );
      currentLocale = LocaleConstants.zhTW;
    }

    if (joystoreName != LocaleConstants.joystoreZhTW) {
      await storage.saveString(
        key: 'joystoreName',
        value: LocaleConstants.joystoreZhTW,
      );
      joystoreName = LocaleConstants.joystoreZhTW;
    }

    LocaleConstants.currentLocale = currentLocale;
    LocaleConstants.joystoreName = joystoreName;

    // 4) Package info (app name/version)
    final packageInfo = await PackageInfo.fromPlatform();
    AppConfig.appName = packageInfo.appName;
    AppConfig.appVersion = packageInfo.version;
    AppConfig.appPackageName = packageInfo.packageName;

    // 5) Desktop window setup (non-blocking)
    await setupWindow();

    // Test Generative AI Service
    final aiService = AIFactory.create();

    Future<void> runAI() async {
      final result = await aiService.generateText(
        "Write a Psalm-like blessing",
      );
      print(result);
    }
  }
}

// --- DESKTOP WINDOW SETUP -----------------------------------
const double windowWidth = 480;
const double windowHeight = 854;

Future<void> setupWindow() async {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // Ensure the widget binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    setWindowTitle('AbideVerse'); // or use localization if needed

    const double windowWidth = 480;
    const double windowHeight = 854;

    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));

    final screen = await getCurrentScreen();
    if (screen != null) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    }
  }
}
