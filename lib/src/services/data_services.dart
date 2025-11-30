import 'package:shared_preferences/shared_preferences.dart';

import '../data/global_config.dart';

class abideverseDataServices {
  abideverseDataServices._(); // Private constructor to prevent instantiation

  /*
 *----------------------------------------------
 * Store key-value data on disk
 * Source: [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
 *----------------------------------------------
 */
  static Future<bool> saveDataStoreKeyValueDataOnDisk({
    required String key,
    required String value,
  }) async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Save the value to persistent storage under the key.
    var rcode = await prefs.setString(key, value);

    return rcode;
  }

  static Future<String> loadDataStoreKeyValueDataOnDisk({
    required String key,
    required String defaultValue,
  }) async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Save the value to persistent storage under the key.
    var rcode = prefs.getString(key) ?? defaultValue;

    return rcode;
  }

  static Future<bool> removeDataStoreKeyValueDataOnDisk({
    required String key,
  }) async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Remove the counter key-value pair from persistent storage.
    var rcode = await prefs.remove(key);

    return rcode;
  }
}
