import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abideverse/app/abideverse_app_shell.dart';
import 'package:abideverse/app/more_menu.dart';
import 'package:abideverse/core/config/app_config.dart';

import 'package:abideverse/features/about/screens/about_screen.dart';
import 'package:abideverse/features/bible_chat/screens/bible_chat_screen.dart';
import 'package:abideverse/features/admin/screens/manage_firestore_screen.dart';
import 'package:abideverse/features/auth/data/auth_repository.dart';
import 'package:abideverse/features/auth/screens/sign_in_screen.dart';
import 'package:abideverse/features/home/screens/home_screen.dart';
import 'package:abideverse/features/joys/data/joy_repository.dart';
import 'package:abideverse/features/joys/screens/joy_detail_page.dart';
import 'package:abideverse/features/joys/screens/joys_page.dart';
import 'package:abideverse/features/scriptures/screens/scripture_detail_page.dart';
import 'package:abideverse/features/resources/screens/resources_screen.dart';
import 'package:abideverse/features/scriptures/screens/scriptures_page.dart';
import 'package:abideverse/features/treasures/screens/treasure_detail_page.dart';
import 'package:abideverse/features/treasures/screens/treasures_page.dart';
import 'package:abideverse/shared/services/ai/ai_factory.dart';
import 'package:abideverse/features/settings/screens/settings.dart';
import 'package:abideverse/shared/widgets/fade_transition_page.dart';
import 'package:abideverse/shared/widgets/markdown_viewer.dart';
import 'package:abideverse/features/gallery/screens/gallery_screen.dart';

class AppRoutes {
  static const home = '/';

  static const joys = '/joys';
  static const joysDetail = '/joys/joy/:articleId';

  static const scriptures = '/scriptures';
  static const scriptureDetail = '/scriptures/scripture/:articleId';

  static const treasures = '/treasures';
  static const treasureDetail = '/treasures/treasure/:articleId';

  static const bibleChat = '/bible-chat';
  static const about = '/about';

  static const resources = '/resources';
  static const resourcesMarkdown = '/resources/markdown/:title/:assetPath';

  static const settings = '/settings';

  static const signIn = '/sign-in';
  static const firestoreAdmin = '/firestore-admin';

  static const gallery = '/gallery';

  static const more = '/more';
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
      // if (!joyAuth.signedIn && path != AppRoutes.signIn) {
      //   return AppRoutes.signIn;
      // }

      // Allow home screen, sign-in screen, and maybe about/resources without auth
      final publicRoutes = [
        AppRoutes.home,
        AppRoutes.signIn,
        AppRoutes.about,
        AppRoutes.resources,
      ];

      if (!joyAuth.signedIn && !publicRoutes.any((r) => path.startsWith(r))) {
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

    // -----------------------------
    // TREASURE DETAIL GUARD
    // (No repository yet; only ensures ID is valid)
    // -----------------------------
    if (path.startsWith('/treasures/treasure/')) {
      final ok = validateArticleRoute(
        state: state,
        redirectTo: AppRoutes.treasures,
        exists: (_) => true, // Always passes, until you add a repository
      );
      if (!ok) return AppRoutes.treasures;
    }

    return null;
  }

  // Instantiate the AI Service only once for the whole router config
  final aiService = AIFactory.create();

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.home, // Changed from AppRoutes.joys
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
            '/joys': 1,
            '/scriptures': 2,
            '/treasures': 3,
            '/bible-chat': 4, // Map to 4 so the 'More' tab stays lit
            '/gallery': 5,
            '/resources': 6,
            '/settings': 7,
            '/about': 8,
            '/more': 4,
          };

          // Special handling for home
          int selectedIndex;
          if (state.uri.path == '/') {
            selectedIndex = 0; // Exact home match
          } else {
            selectedIndex = indexMap.entries
                .firstWhere(
                  (e) => state.uri.path.startsWith(e.key),
                  orElse: () => const MapEntry('/', 1),
                )
                .value;
          }

          return AbideVerseAppShell(selectedIndex: selectedIndex, child: child);
        },
        routes: [
          // --------------------------
          // HOME
          // --------------------------
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                fadePage(const HomeScreen(), state.pageKey),
          ),

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
          // TREASURES
          // --------------------------
          GoRoute(
            path: AppRoutes.treasures,
            pageBuilder: (context, state) => fadePage(
              TreasuresPage(locale: context.locale.toLanguageTag()),
              state.pageKey,
            ),
          ),

          GoRoute(
            path: AppRoutes.treasureDetail,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['articleId']!);
              return TreasureDetailPage(
                articleId: id,
                locale: context.locale.toLanguageTag(),
              );
            },
          ),

          // --------------------------
          // BIBLE CHAT
          // --------------------------
          GoRoute(
            path: AppRoutes.bibleChat,
            pageBuilder: (context, state) => fadePage(
              BibleChatScreen(
                aiService: aiService,
              ), // <-- Use the factory instance
              state.pageKey,
            ),
          ),

          // --------------------------
          // GALLERY
          // --------------------------
          GoRoute(
            path: AppRoutes.gallery,
            pageBuilder: (context, state) =>
                fadePage(const GalleryScreen(), state.pageKey),
          ),

          // --------------------------
          // RESOURCES
          // --------------------------
          GoRoute(
            path: AppRoutes.resources,
            builder: (context, state) => const ResourcesScreen(),
            pageBuilder: (context, state) =>
                fadePage(ResourcesScreen(), state.pageKey),
          ),

          GoRoute(
            path: AppRoutes.resourcesMarkdown,
            builder: (context, state) {
              final title = state.pathParameters['title'] ?? 'Content';
              final assetPath = state.pathParameters['assetPath'] ?? '';
              return MarkdownViewer(assetPath: assetPath, title: title);
            },
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

          // --------------------------
          // ABOUT
          // --------------------------
          GoRoute(
            path: AppRoutes.about,
            pageBuilder: (context, state) =>
                fadePage(AboutScreen(firestore: firestore), state.pageKey),
          ),

          // --------------------------
          // MORE MENU
          // --------------------------
          GoRoute(
            path: AppRoutes.more,
            pageBuilder: (context, state) =>
                fadePage(const MoreMenuScreen(), state.pageKey),
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
        path: AppRoutes.firestoreAdmin,
        pageBuilder: (context, state) =>
            fadePage(FirestoreAdminScreen(firestore: firestore), state.pageKey),
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

  void goHome() => context.go(AppRoutes.home);

  void goJoys() => context.go(AppRoutes.joys);

  void pushJoyDetail(int articleId) => context.push(
    AppRoutes.joysDetail.replaceFirst(':articleId', '$articleId'),
  );

  void goScriptures() => context.go(AppRoutes.scriptures);

  void pushScriptureDetail(int articleId) => context.push(
    AppRoutes.scriptureDetail.replaceFirst(':articleId', '$articleId'),
  );

  void goTreasures() => context.go(AppRoutes.treasures);

  void pushTreasureDetail(int articleId) => context.push(
    AppRoutes.treasureDetail.replaceFirst(':articleId', '$articleId'),
  );

  void goBibleChat() => context.go(AppRoutes.bibleChat);

  void goMore() => context.go(AppRoutes.more);
  void goAbout() => context.go(AppRoutes.about);
  void goResources() => context.go(AppRoutes.resources);
  void goSettings() => context.go(AppRoutes.settings);
  void goGallery() => context.go(AppRoutes.gallery);

  void goSignIn() => context.go(AppRoutes.signIn);
  void goFirestoreAdmin() => context.go(AppRoutes.firestoreAdmin);
}
