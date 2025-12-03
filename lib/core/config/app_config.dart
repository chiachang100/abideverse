/// App-wide static configuration flags and metadata.
/// These are compile/runtime configuration values used across the app.
///
/// Use only for lightweight flags and metadata. Do NOT put runtime-initialized
/// services (Firebase, JoyStore) here — those belong in services/.
class AppConfig {
  // Feature toggles / flags
  static const bool enableSignIn = false;
  static const bool useYoutubePlayerFlutter = true;
  static const bool useFilestore = false;

  // App metadata (set at runtime in main.dart if desired)
  static String appName = 'AbideVerse';
  static String appVersion = '0.0.0';
  static String appPackageName = 'com.joyolord.abideverse';
}
