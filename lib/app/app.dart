import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:abideverse/features/auth/data/auth_repository.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/services/db/joystore_service.dart';
import 'package:abideverse/app/router.dart';

final appShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'app shell');
final joysNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'joys shell');
final abideverselogAppJoystore = Logger('app_joystore');

class Joystore extends StatefulWidget {
  const Joystore({super.key, required this.firestore});

  final FirebaseFirestore firestore;

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  State<Joystore> createState() => _JoystoreState();
}

class _JoystoreState extends State<Joystore> {
  final JoystoreAuth joyAuth = JoystoreAuth();
  final JoyStoreService joyStoreService = JoyStoreService.instance;

  late final GoRouter router;

  @override
  void initState() {
    super.initState();

    // Initialize router safely
    router = createRouter(
      firestore: widget.firestore,
      joyAuth: joyAuth,
      joyStoreService: joyStoreService,
    );

    // Log analytics screen view
    _logScreenView('MainAppScreen');

    // Firestore test asynchronously
    _initAsync();
  }

  // Helper: Async initialization
  Future<void> _initAsync() async {
    await _testFirestore();
    await _loadJoyStore();
  }

  Future<void> _testFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('test')
          .doc('ping')
          .get();
      debugPrint('Firestore connected: ${doc.exists}');
      abideverselogAppJoystore.info(
        '[MainAppScreen] Firestore connected: ${doc.exists}',
      );
    } catch (e, st) {
      debugPrint('Firestore error: $e');
      debugPrint(' Stack: $st');
      abideverselogAppJoystore.severe(
        '[MainAppScreen] Firestore error: $e',
        e,
        st,
      );
    }
  }

  Future<void> _loadJoyStore() async {
    final js = await joyStoreService.loadFromFirestore();
    joyStoreService.joystore = js;
    // If your UI depends on the joystore, uncomment next line
    // setState(() {});
  }

  void _logScreenView(String screenName) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'abideverse_screen': screenName,
        'abideverse_screen_class': runtimeType.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
          bodyMedium: Theme.of(context).textTheme.titleMedium,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        if (child == null) throw 'No child in MaterialApp.router builder';
        abideverselogAppJoystore.info(
          '[MainAppScreen] Locale=${context.locale.toString()}; '
          'joysCurrentLocale=${LocaleConstants.currentLocale}; '
          'joystoreName=${LocaleConstants.joystoreName}',
        );
        return JoystoreAuthScope(notifier: joyAuth, child: child);
      },
    );
  }
}
