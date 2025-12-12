import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abideverse/app/abideverse_app_shell.dart';
import 'package:abideverse/core/config/app_config.dart';

import 'package:abideverse/features/about/screens/about_screen.dart';
import 'package:abideverse/features/bible_assistant/screens/bible_assistant_screen.dart';
import 'package:abideverse/features/admin/screens/manage_firestore_screen.dart';
import 'package:abideverse/features/auth/data/auth_repository.dart';
import 'package:abideverse/features/auth/screens/sign_in_screen.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/features/joys/screens/joy_detail_page.dart';
import 'package:abideverse/features/joys/screens/joys_page.dart';
import 'package:abideverse/features/scriptures/screens/scripture_detail_page.dart';
import 'package:abideverse/features/scriptures/screens/scriptures_page.dart';
import 'package:abideverse/shared/services/ai/ai_factory.dart';
import 'package:abideverse/features/settings/screens/settings.dart';
import 'package:abideverse/shared/widgets/fade_transition_page.dart';

class AppRoutes {
  static const joys = '/joys';
  static const joysDetail = '/joys/joy/:articleId';

  static const scriptures = '/scriptures';
  static const scriptureDetail = '/scriptures/scripture/:articleId';

  static const bibleAssitant = '/bible-assitant';
  static const about = '/about';
  static const settings = '/settings';

  static const signIn = '/sign-in';
  static const manageFirestore = '/manage-firestore';
}

final GlobalKey<NavigatorState> appShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'appShell');

Page<void> fadePage(Widget child, LocalKey key) =>
    FadeTransitionPage(key: key, child: child);

/// -------------------------------------------------------------------------
/// SHARED CONTENT-GUARD FUNCTION
/// -------------------------------------------------------------------------
/// Validates any "content detail page" that depends on an integer articleId.
/// You pass:
///   - GoRouterState
///   - The valid base route to redirect to if validation fails
///   - A function that checks if the content exists (repository lookup)
///
/// This removes duplicated guard logic.
/// -------------------------------------------------------------------------
bool validateArticleRoute({
  required GoRouterState state,
  required String redirectTo,
  required bool Function(int id) exists,
}) {
  final raw = state.pathParameters['articleId'];
  final id = int.tryParse(raw ?? '');
  if (id == null) return false;
  return exists(id);
}

/// -------------------------------------------------------------------------
/// ROUTER
/// -------------------------------------------------------------------------
GoRouter createRouter({
  required FirebaseFirestore firestore,
  required JoystoreAuth joyAuth,
  required JoyRepository joyRepository,
}) {
  String? guardRedirect(BuildContext context, GoRouterState state) {
    final path = state.uri.toString();

    // -----------------------------
    // AUTH GUARD
    // -----------------------------
    if (AppConfig.enableSignIn) {
      if (!joyAuth.signedIn && path != AppRoutes.signIn) {
        return AppRoutes.signIn;
      }
    }

    // -----------------------------
    // JOY DETAIL GUARD
    // -----------------------------
    if (path.startsWith('/joys/joy/')) {
      final ok = validateArticleRoute(
        state: state,
        redirectTo: AppRoutes.joys,
        exists: (id) => joyRepository.getJoy(id) != null,
      );
      if (!ok) return AppRoutes.joys;
    }

    // -----------------------------
    // SCRIPTURE DETAIL GUARD
    // (No repository yet; only ensures ID is valid)
    // -----------------------------
    if (path.startsWith('/scriptures/scripture/')) {
      final ok = validateArticleRoute(
        state: state,
        redirectTo: AppRoutes.scriptures,
        exists: (_) => true, // Always passes, until you add a repository
      );
      if (!ok) return AppRoutes.scriptures;
    }

    return null;
  }

  // Instantiate the AI Service only once for the whole router config
  final aiService = AIFactory.create();

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.joys,
    refreshListenable: joyAuth,
    redirect: guardRedirect,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [
      // --------------------------
      // MAIN SHELL
      // --------------------------
      ShellRoute(
        navigatorKey: appShellNavigatorKey,
        builder: (context, state, child) {
          final indexMap = {
            '/joys': 0,
            '/scriptures': 1,
            '/bible-assitant': 2,
            '/about': 3,
            '/settings': 4,
          };

          final selectedIndex = indexMap.entries
              .firstWhere(
                (e) => state.uri.path.startsWith(e.key),
                orElse: () => const MapEntry('', 0),
              )
              .value;

          return AbideVerseAppShell(selectedIndex: selectedIndex, child: child);
        },
        routes: [
          // --------------------------
          // JOYS
          // --------------------------
          GoRoute(
            path: AppRoutes.joys,
            pageBuilder: (context, state) => fadePage(
              JoysPage(locale: context.locale.toLanguageTag()),
              state.pageKey,
            ),
          ),

          GoRoute(
            path: AppRoutes.joysDetail,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['articleId']!);
              return JoyDetailPage(
                articleId: id,
                locale: context.locale.toLanguageTag(),
              );
            },
          ),

          // --------------------------
          // SCRIPTURES
          // --------------------------
          GoRoute(
            path: AppRoutes.scriptures,
            pageBuilder: (context, state) => fadePage(
              ScripturesPage(locale: context.locale.toLanguageTag()),
              state.pageKey,
            ),
          ),

          GoRoute(
            path: AppRoutes.scriptureDetail,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['articleId']!);
              return ScriptureDetailPage(
                articleId: id,
                locale: context.locale.toLanguageTag(),
              );
            },
          ),

          // --------------------------
          // AI CHAT
          // --------------------------
          GoRoute(
            path: AppRoutes.bibleAssitant,
            pageBuilder: (context, state) => fadePage(
              BibleAssitantScreen(
                aiService: aiService,
              ), // <-- Use the factory instance
              state.pageKey,
            ),
          ),
          // --------------------------
          // ABOUT
          // --------------------------
          GoRoute(
            path: AppRoutes.about,
            pageBuilder: (context, state) =>
                fadePage(AboutScreen(firestore: firestore), state.pageKey),
          ),

          // --------------------------
          // SETTINGS
          // --------------------------
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => fadePage(
              SettingsScreen(
                firestore: firestore,
                joyRepository: joyRepository,
              ),
              state.pageKey,
            ),
          ),
        ],
      ),

      // --------------------------
      // SIGN-IN
      // --------------------------
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInScreen(
          onSignIn: (value) async {
            await joyAuth.signIn(value.email, value.password);
            Routes(context).goJoys();
          },
        ),
      ),

      // --------------------------
      // FIRESTORE ADMIN
      // --------------------------
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

/// -------------------------------------------------------------------------
/// NAVIGATION HELPERS
/// -------------------------------------------------------------------------
class Routes {
  final BuildContext context;
  Routes(this.context);

  void goJoys() => context.go(AppRoutes.joys);

  void pushJoyDetail(int articleId) => context.push(
    AppRoutes.joysDetail.replaceFirst(':articleId', '$articleId'),
  );

  void goScriptures() => context.go(AppRoutes.scriptures);

  void pushScriptureDetail(int articleId) => context.push(
    AppRoutes.scriptureDetail.replaceFirst(':articleId', '$articleId'),
  );

  void goBibleAssitant() => context.go(AppRoutes.bibleAssitant);

  void goAbout() => context.go(AppRoutes.about);
  void goSettings() => context.go(AppRoutes.settings);
  void goSignIn() => context.go(AppRoutes.signIn);
  void goManageFirestore() => context.go(AppRoutes.manageFirestore);
}
