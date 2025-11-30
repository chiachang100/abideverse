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
import 'src/app.dart';
import 'src/data/data_index.dart';
import 'src/services/locale_services.dart';
import 'src/services/data_services.dart';
import 'src/models/locale_info_model.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/l10n/codegen_loader.g.dart';
import 'package:abideverse/l10n/locale_keys.g.dart';

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

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve the splash screen during the initialization.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
  );

  //------------------------------------------
  // Setup Firebase
  //------------------------------------------
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

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
  joysCurrentLocale = LOCALE_ZH_TW;
  joystoreName = JOYSTORE_NAME_ZH_TW;

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  abideverselogMain.info(
    '[Main-default] joysCurrentLocale=$joysCurrentLocale; joystoreName=$joystoreName',
  );

  joystoreInstance = buildJoyStoreFromLocal();

  // joysCurrentLocale = LOCALE_ZH_CN;
  // joystoreName = JOYSTORE_NAME_ZH_CN;

  // Load 'joysCurrentLocale' and 'joystoreName' from the local store.
  abideverseDataServices
      .loadDataStoreKeyValueDataOnDisk(
        key: 'joysCurrentLocale',
        defaultValue: joysCurrentLocale,
      )
      // .then((result) => joysCurrentLocale = result.toString());
      .then((result) {
        joysCurrentLocale = result.toString();

        abideverseDataServices
            .loadDataStoreKeyValueDataOnDisk(
              key: 'joystoreName',
              defaultValue: joystoreName,
            )
            // .then((result) => joystoreName = result.toString());
            .then((result) {
              joystoreName = result.toString();
              joystoreInstance = buildJoyStoreFromFirestoreOrLocal(prod: true);
              abideverselogMain.info(
                '[Main-loading] joysCurrentLocale=$joysCurrentLocale; joystoreName=$joystoreName',
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
    '[Main-calling-Joystore] joysCurrentLocale=$joysCurrentLocale; joystoreName=$joystoreName',
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

  appName = packageInfo.appName;
  appVersion = packageInfo.version.toString();
  appPkgName = packageInfo.packageName;

  // appName = 'abideverse';
  // appVersion = '1.9.0';
  // appPkgName = 'abideverse';
  abideverselogMain.info(
    '[Main-loading] appName=$appName; appVersion=$appVersion; appPkgName=$appPkgName',
  );
  abideverselogMain.info(
    '[Main-loading] joysCurrentLocale=$joysCurrentLocale; joystoreName=$joystoreName',
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
