/// Locale and datastore name constants and current selections.
/// These are simple, mutable values (for current choices) or constants
/// (for canonical locale name strings).
library;

class LocaleConstants {
  // Canonical locale codes
  static const String enUS = 'en_US';
  static const String zhCN = 'zh_CN';
  static const String zhTW = 'zh_TW';
  static const String defaultLocale = zhTW;

  // Current locale selection (mutable at runtime)
  static String currentLocale = zhTW;

  // Joystore (data store) name constants
  static const String joystoreDefault = 'joys';
  static const String joystoreEnUS = 'joys_en_US';
  static const String joystoreZhCN = 'joys_zh_CN';
  static const String joystoreZhTW = 'joys_zh_TW';

  // Active joystore name (mutable, defaults to zh_TW name)
  static String joystoreName = joystoreZhTW;
}
