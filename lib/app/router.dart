import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abideverse/features/joys/screens/joy_details_screen.dart';
import 'package:abideverse/features/joys/widgets/joy_list.dart';
import 'package:abideverse/features/joys/widgets/joy_scaffold.dart';
import 'package:abideverse/features/scriptures/screens/scriptures_page.dart';
import 'package:abideverse/features/scriptures/screens/detailed_scripture_page.dart';
import 'package:abideverse/features/about/screens/about_screen.dart';
import 'package:abideverse/features/settings/screens/settings.dart';
import 'package:abideverse/features/auth/screens/sign_in_screen.dart';
import 'package:abideverse/features/admin/screens/manage_firestore_screen.dart';
import 'package:abideverse/widgets/fade_transition_page.dart';
import 'package:abideverse/services/db/joystore_service.dart';
import 'package:abideverse/features/auth/data/auth_repository.dart';

class AppRoutes {
  static const joys = '/joys';
  static const joysDetail = '/joys/joy/:joyId';
  static const scriptures = '/scriptures';
  static const scriptureDetail = '/scriptures/scripture/:articleId';
  static const about = '/about';
  static const settings = '/settings';
  static const signIn = '/sign-in';
  static const manageFirestore = '/manage-firestore';
}

final GlobalKey<NavigatorState> appShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app shell');

String formattedLocale(BuildContext context) =>
    context.locale.toString().replaceAll('_', '-');

Page<void> fadePage(Widget child, LocalKey key) =>
    FadeTransitionPage(key: key, child: child);

GoRouter createRouter({
  required FirebaseFirestore firestore,
  required JoystoreAuth joyAuth,
  required JoyStoreService joyStoreService,
}) {
  String? guardRedirect(BuildContext context, GoRouterState state) {
    final path = state.uri.toString();

    if (!joyAuth.signedIn && path != AppRoutes.signIn) {
      return AppRoutes.signIn;
    }

    if (path.startsWith('/joys/joy/')) {
      final joyId = state.pathParameters['joyId'];
      final joyExists =
          joyId != null && joyStoreService.joystore.getJoy(joyId) != null;
      if (!joyExists) return AppRoutes.joys;
    }

    if (path.startsWith('/scriptures/scripture/')) {
      final id = int.tryParse(state.pathParameters['articleId'] ?? '');
      if (id == null) return AppRoutes.scriptures;
    }

    return null;
  }

  return GoRouter(
    debugLogDiagnostics: true,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    initialLocation: AppRoutes.joys,
    refreshListenable: joyAuth,
    redirect: guardRedirect,
    routes: [
      ShellRoute(
        navigatorKey: appShellNavigatorKey,
        builder: (context, state, child) {
          final indexMap = {
            '/joys': 0,
            '/scriptures': 1,
            '/about': 2,
            '/settings': 3,
          };
          int selectedIndex = indexMap.entries
              .firstWhere(
                (e) => state.uri.path.startsWith(e.key),
                orElse: () => MapEntry('', 0),
              )
              .value;
          return JoystoreScaffold(selectedIndex: selectedIndex, child: child);
        },
        routes: [
          // Joys
          GoRoute(
            path: AppRoutes.joys,
            pageBuilder: (context, state) => fadePage(
              JoyList(
                joys: joyStoreService.joystore.wholeJoys,
                onTap: (joy) => Routes(context).pushJoyDetail(joy.id),
              ),
              state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.joysDetail,
            parentNavigatorKey: appShellNavigatorKey,
            builder: (context, state) {
              final joyId = state.pathParameters['joyId']!;
              final joy = joyStoreService.joystore.getJoy(joyId)!;
              return JoyDetailsScreen(joy: joy);
            },
          ),
          // Scriptures
          GoRoute(
            path: AppRoutes.scriptures,
            pageBuilder: (context, state) => fadePage(
              ScripturesPage(locale: formattedLocale(context)),
              state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.scriptureDetail,
            builder: (context, state) {
              final articleId = int.parse(state.pathParameters['articleId']!);
              return DetailedScripturePage(
                articleId: articleId,
                locale: formattedLocale(context),
              );
            },
          ),
          // About
          GoRoute(
            path: AppRoutes.about,
            pageBuilder: (context, state) =>
                fadePage(AboutScreen(firestore: firestore), state.pageKey),
          ),
          // Settings
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                fadePage(SettingsScreen(firestore: firestore), state.pageKey),
          ),
        ],
      ),
      // Sign In
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInScreen(
          onSignIn: (value) async {
            await joyAuth.signIn(value.email, value.password);
            Routes(context).goJoys();
          },
        ),
      ),
      // Manage Firestore
      GoRoute(
        path: AppRoutes.manageFirestore,
        pageBuilder: (context, state) => fadePage(
          ManageFirestoreScreen(firestore: firestore),
          state.pageKey,
        ),
      ),
    ],
  );
}

/// Type-safe navigation helper
class Routes {
  final BuildContext context;

  Routes(this.context);

  void goJoys() => context.go(AppRoutes.joys);

  void pushJoyDetail(int joyId) =>
      context.push(AppRoutes.joysDetail.replaceFirst(':joyId', '$joyId'));

  void goScriptures() => context.go(AppRoutes.scriptures);

  void pushScriptureDetail(int articleId) => context.push(
    AppRoutes.scriptureDetail.replaceFirst(':articleId', '$articleId'),
  );

  void goAbout() => context.go(AppRoutes.about);

  void goSettings() => context.go(AppRoutes.settings);

  void goSignIn() => context.go(AppRoutes.signIn);

  void goManageFirestore() => context.go(AppRoutes.manageFirestore);
}
