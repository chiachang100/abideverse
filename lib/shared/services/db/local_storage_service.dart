import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  LocalStorageService._(); // Private constructor to prevent instantiation

  // Singleton instance
  static final LocalStorageService instance = LocalStorageService._();

  /*
 *----------------------------------------------
 * Store key-value data on disk
 * Source: [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
 *----------------------------------------------
 */
  Future<bool> saveString({required String key, required String value}) async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Save the value to persistent storage under the key.
    var rcode = await prefs.setString(key, value);

    return rcode;
  }

  Future<String> getString({
    required String key,
    required String defaultValue,
  }) async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Save the value to persistent storage under the key.
    var rcode = prefs.getString(key) ?? defaultValue;

    return rcode;
  }

  Future<bool> removeKey({required String key}) async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Remove the counter key-value pair from persistent storage.
    var rcode = await prefs.remove(key);

    return rcode;
  }

  Future<bool> hasKey({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<void> saveJson({
    required String key,
    required Map<String, dynamic> data,
  }) async {
    final jsonStr = jsonEncode(data);
    await saveString(key: key, value: jsonStr);
  }

  Future<Map<String, dynamic>?> getJson({required String key}) async {
    final jsonStr = await getString(key: key, defaultValue: "");

    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
