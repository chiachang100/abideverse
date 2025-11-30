import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../data/global_config.dart';

class LocaleInfoModel extends ChangeNotifier {
  static String joysCurrentLocale = LOCALE_ZH_TW;
  static String joystoreName = JOYSTORE_NAME_ZH_TW;

  var localeInfoRecords = <String, String>{
    // 'locale': 'zh_TW',
    // 'store': 'joys_zh_tw',
    'locale': joysCurrentLocale,
    'store': joystoreName,
  };

  String get localeName => localeInfoRecords['locale'] as String;
  String get storeName => localeInfoRecords['store'] as String;

  String get localeName2 => joysCurrentLocale;
  String get storeName2 => joystoreName;

  void setAppLocaleInfo(Map<String, String> json) {
    joysCurrentLocale = json['locale'] as String;
    joystoreName = json['store'] as String;
    localeInfoRecords['locale'] = json['locale'] as String;
    localeInfoRecords['store'] = json['store'] as String;
    notifyListeners();
  }

  (String locale, String store) getAppLocaleInfo() {
    return (
      localeInfoRecords['locale'] as String,
      localeInfoRecords['store'] as String,
    );
  }

  ({String locale, String store}) getAppLocaleInfo2() {
    return (
      locale: localeInfoRecords['locale'] as String,
      store: localeInfoRecords['store'] as String,
    );
  }
}
