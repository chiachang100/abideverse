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
import 'services/db/local_storage_service.dart';
import 'models/locale_info_model.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/core/config/app_config.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/services/db/joystore_service.dart';
import 'package:abideverse/services/firebase/firebase_service.dart';

import 'package:package_info_plus/package_info_plus.dart';

final abideverselogMain = Logger('main');
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

  late LocalStorageService storage;

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
  // Setup Locale and JoyStore instance
  //------------------------------------------
  // joystoreName = JOYSTORE_NAME_DEFAULT;

  // Set the default values
  LocaleConstants.currentLocale = LocaleConstants.zhTW;
  LocaleConstants.joystoreName = LocaleConstants.joystoreZhTW;

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  abideverselogMain.info(
    '[Main-default] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
  );

  JoyStoreService.instance.joystore = JoyStoreService.instance
      .loadLocalJoyStore();
  storage = LocalStorageService.instance;

  // joysCurrentLocale = LOCALE_ZH_CN;
  // joystoreName = JOYSTORE_NAME_ZH_CN;

  // Load 'joysCurrentLocale' and 'joystoreName' from the local store.
  storage
      .getString(
        key: 'joysCurrentLocale',
        defaultValue: LocaleConstants.currentLocale,
      )
      // .then((result) => joysCurrentLocale = result.toString());
      .then((result) {
        LocaleConstants.currentLocale = result.toString();

        storage
            .getString(
              key: 'joystoreName',
              defaultValue: LocaleConstants.joystoreName,
            )
            // .then((result) => joystoreName = result.toString());
            .then((result) {
              LocaleConstants.joystoreName = result.toString();
              JoyStoreService.instance
                  .loadFirestoreOrLocal(prod: true)
                  .then((js) => JoyStoreService.instance.joystore = js);

              abideverselogMain.info(
                '[Main-loading] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
              );
            });
      });

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

  abideverselogMain.info(
    '[Main-calling-Joystore] joysCurrentLocale=${LocaleConstants.currentLocale}; joystoreName=${LocaleConstants.joystoreName}',
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

  // appName = 'abideverse';
  // appVersion = '1.9.0';
  // appPkgName = 'abideverse';
  abideverselogMain.info(
    '[Main-loading] appName=${AppConfig.appName}; appVersion=${AppConfig.appVersion}; appPkgName=${AppConfig.appPackageName}',
  );
  abideverselogMain.info(
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
    // setWindowTitle('笑裡藏道');
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
