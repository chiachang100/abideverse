/// App-wide static configuration flags and metadata.
/// These are compile/runtime configuration values used across the app.
///
/// Use only for lightweight flags and metadata. Do NOT put runtime-initialized
/// services (Firebase, JoyStore) here — those belong in services/.
library;

enum SortOrder { asc, desc }

enum AIProvider { genAI, firebaseAI }

class AppConfig {
  // App metadata (set at runtime in main.dart if desired)
  static String appName = 'AbideVerse';
  static String appVersion = '0.0.0';
  static String appPackageName = 'com.joyolord.abideverse';

  // Feature toggles / flags
  static const bool enableSignIn = false;
  static const bool useYoutubePlayerFlutter = true;
  static const bool useFilestore = false;
  static const bool enableLikeButton = false;
  static const bool enableEnglishButton = false;

  //static AIProvider aiProvider = AIProvider.genAI;
  static AIProvider aiProvider = AIProvider.firebaseAI;

  // Global forceReloadRepo flag
  static bool forceReloadRepo = false;
}
