/// Locale and datastore name constants and current selections.
/// These are simple, mutable values (for current choices) or constants
/// (for canonical locale name strings).
library;

class LocaleConstants {
  // Canonical locale codes
  static const String enUS = 'en-US';
  static const String zhCN = 'zh-CN';
  static const String zhTW = 'zh-TW';
  static const String defaultLocale = zhTW;

  // Current locale selection (mutable at runtime)
  static String currentLocale = zhTW;

  // Joystore (data store) name constants
  static const String joystoreDefault = 'joys';
  static const String joystoreEnUS = 'joys_en-US';
  static const String joystoreZhCN = 'joys_zh-CN';
  static const String joystoreZhTW = 'joys_zh-TW';

  // Active joystore name (mutable, defaults to zh-TW name)
  static String joystoreName = joystoreZhTW;
}
