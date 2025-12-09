import 'dart:io' show Platform;
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_size/window_size.dart';

import 'package:abideverse/startup/abideverse_root.dart';
import 'package:abideverse/startup/startup_screen.dart';
import 'package:abideverse/shared/models/locale_info_model.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

final abideverseLogMain = Logger('main');
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
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // keep lightweight: print only essential
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Minimal required init
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash until we explicitly remove it in StartupScreen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // System chrome style quickly
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
  );

  // Setup url strategy for web (no blocking)
  setPathUrlStrategy();

  // Setup window (non-blocking call)
  _maybeSetupWindow();

  // Ensure easy_localization is ready
  await EasyLocalization.ensureInitialized();

  // Run the app as fast as possible
  runApp(
    EasyLocalization(
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
