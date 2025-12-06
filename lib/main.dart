import 'dart:async';
import 'dart:io' show Platform;
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_size/window_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app/app.dart';
import 'shared/services/db/local_storage_service.dart';
import 'shared/models/locale_info_model.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/shared/services/firebase/firebase_service.dart';

import 'package:package_info_plus/package_info_plus.dart';

final abideverseLogMain = Logger('main');
final kDefaultLocale = const Locale('zh', 'TW');

class L10n {
  static final allLocales = [
    // const Locale('en'),
    // const Locale('zh'),
    const Locale('en', 'US'),
    const Locale('zh', 'CN'),
    const Locale('zh', 'TW'),
  ];
}

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve the splash screen during the initialization.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
  );

  //------------------------------------------
  // Setup Firebase
  //------------------------------------------
  FirebaseService.instance.app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseService.instance.auth = FirebaseAuth.instanceFor(
    app: FirebaseService.instance.app,
  );

  final firestore = FirebaseFirestore.instance;

  final settings = firestore.settings.copyWith(persistenceEnabled: true);
  final updatedSettings = firestore.settings.copyWith(
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  //firestore.settings = settings;

  //------------------------------------------
  // Setup Locale
  //------------------------------------------

  // Set the default values
  LocaleConstants.currentLocale = LocaleConstants.zhTW;
  LocaleConstants.joystoreName = LocaleConstants.joystoreZhTW;

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  abideverseLogMain.info(
    '[Main-default] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
  );

  // -----------------------------
  // Fix saved locale keys if inconsistent
  // -----------------------------
  final storage = LocalStorageService.instance;

  String currentLocale = await storage.getString(
    key: 'joysCurrentLocale',
    defaultValue: LocaleConstants.currentLocale,
  );

  String joystoreName = await storage.getString(
    key: 'joystoreName',
    defaultValue: LocaleConstants.joystoreName,
  );

  // Normalize the values to match your renamed asset
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

  abideverseLogMain.info(
    '[Main-loading-fixedKeys] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
  );

  // if (kIsWeb) {
  //   // await FirebaseAuth.instance.setPersistence(Persistence.NONE);
  //   await auth.setPersistence(Persistence.LOCAL);
  // }

  // if (!kReleaseMode) {
  //   FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //   //FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);
  //   //FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  // }

  // Use package:url_strategy until this pull request is released:
  // https://github.com/flutter/flutter/pull/77103

  // Use to setHashUrlStrategy() to use "/#/" in the address bar (default). Use
  // setPathUrlStrategy() to use the path. You may need to configure your web
  // server to redirect all paths to index.html.
  //
  // On mobile platforms, both functions are no-ops.
  // setHashUrlStrategy();
  setPathUrlStrategy();

  setupWindow();

  // Remove the splash screen.
  FlutterNativeSplash.remove();

  abideverseLogMain.info(
    '[Main] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
  );

  runApp(
    // Add easy_localization widget
    EasyLocalization(
      supportedLocales: L10n.allLocales,
      path: 'assets/translations',
      fallbackLocale: kDefaultLocale,
      startLocale: kDefaultLocale,
      saveLocale: true,
      child: ChangeNotifierProvider(
        create: (context) => LocaleInfoModel(),
        child: Joystore(firestore: firestore),
      ),
    ),
  );

  // Get pubspec.yaml info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  AppConfig.appName = packageInfo.appName;
  AppConfig.appVersion = packageInfo.version.toString();
  AppConfig.appPackageName = packageInfo.packageName;

  abideverseLogMain.info(
    '[Main-loading] appName=${AppConfig.appName}; appVersion=${AppConfig.appVersion}; appPkgName=${AppConfig.appPackageName}',
  );
  abideverseLogMain.info(
    '[Main-loading] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
  );

  // SystemChrome.setPreferredOrientations(
  //         <DeviceOrientation>[DeviceOrientation.portraitUp])
  //     .then((value) => runApp(Joystore(firestore: firestore)));
}

const double windowWidth = 480;
const double windowHeight = 854;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle(LocaleKeys.appTitle.tr());
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}
