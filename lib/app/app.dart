import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:abideverse/features/auth/data/auth_repository.dart';
import 'package:abideverse/core/constants/locale_constants.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/app/router.dart';
import 'package:abideverse/core/config/app_config.dart';

final appShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'app shell');
final joysNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'joys shell');
final logAppJoystore = Logger('app_joystore');

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

  late final GoRouter router;
  late final Future<void> _loadFuture;

  final joyRepository = JoyRepository(locale: LocaleConstants.currentLocale);

  @override
  void initState() {
    super.initState();

    // Start fetch without awaiting — allows router to build immediately
    _loadFuture = joyRepository.getJoys();

    // Initialize router
    router = createRouter(
      firestore: widget.firestore,
      joyAuth: joyAuth,
      joyRepository: joyRepository,
    );

    // Log analytics
    _logScreenView('AppJoystore');

    // Firestore ping + JoyRepository preload
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _testFirestore();
    await _loadJoyRepository();
  }

  Future<void> _testFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('test')
          .doc('ping')
          .get();

      logAppJoystore.info('[AppJoystore] Firestore connected: ${doc.exists}');
    } catch (e, st) {
      logAppJoystore.severe('[AppJoystore] Firestore error: $e', e, st);
    }
  }

  Future<void> _loadJoyRepository() async {
    await joyRepository.getJoys(order: SortOrder.asc);
    logAppJoystore.info('[AppJoystore] JoyRepository initialized.');
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

        logAppJoystore.info(
          '[AppJoystore] Locale=${context.locale}; '
          'joysCurrentLocale=${LocaleConstants.currentLocale}; '
          'joystoreName=${LocaleConstants.joystoreName}',
        );

        return JoystoreAuthScope(notifier: joyAuth, child: child);
      },
    );
  }
}
