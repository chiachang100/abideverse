/// Locale and datastore name constants and current selections.
/// These are simple, mutable values (for current choices) or constants
/// (for canonical locale name strings).
library;

class LocaleConstants {
  // Canonical locale codes
  static const String enUS = 'en_US';
  static const String zhCN = 'zh_CN';
  static const String zhTW = 'zh_TW';

  // Current locale selection (mutable at runtime)
  static String currentLocale = zhTW;

  // Joystore (data store) name constants
  static const String joystoreDefault = 'joys';
  static const String joystoreEnUS = 'joys_en_us';
  static const String joystoreZhCN = 'joys_zh_cn';
  static const String joystoreZhTW = 'joys_zh_tw';

  // Active joystore name (mutable, defaults to zh-TW name)
  static String joystoreName = joystoreZhTW;
}
