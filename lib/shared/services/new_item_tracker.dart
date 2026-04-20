import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

enum FeatureType { joys, scriptures, treasures }

final logger = Logger('NewItemTracker');

class NewItemTracker {
  static const String _readItemsPrefix = 'read_items_';

  static final NewItemTracker _instance = NewItemTracker._internal();
  factory NewItemTracker() => _instance;
  NewItemTracker._internal();

  late SharedPreferences _prefs;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance._prefs = prefs;
  }

  /// Check if an item should show "NEW" badge
  /// Returns true ONLY if JSON has isNew=true AND user hasn't tapped it yet
  Future<bool> isItemNew(
    FeatureType feature,
    int itemId,
    bool isNewFlag,
  ) async {
    logger.fine(' 📊 TRACKER CALL: id=$itemId, isNewFlag=$isNewFlag');

    if (!isNewFlag) {
      logger.fine(' ⏭️ RETURNING FALSE because isNewFlag=false');

      return false;
    }

    final readKey = '$_readItemsPrefix${feature.name}_$itemId';
    final isRead = _prefs.getBool(readKey) ?? false;
    final result = !isRead;

    logger.fine(' ✅ readKey=$readKey, isRead=$isRead, result=$result');

    return result;
  }

  /// Mark item as read (when user taps)
  Future<void> markItemAsRead(FeatureType feature, int itemId) async {
    final readKey = '$_readItemsPrefix${feature.name}_$itemId';
    await _prefs.setBool(readKey, true);
  }

  /// Get count of new (unread) items
  Future<int> getNewItemsCount<T>(
    FeatureType feature,
    List<T> items,
    bool Function(T item) getIsNewFlag,
    int Function(T item) getId,
  ) async {
    int count = 0;

    for (final item in items) {
      if (getIsNewFlag(item)) {
        final readKey = '$_readItemsPrefix${feature.name}_${getId(item)}';
        final isRead = _prefs.getBool(readKey) ?? false;
        if (!isRead) count++;
      }
    }
    return count;
  }

  /// Mark ALL items as read for a feature
  Future<void> markAllAsRead(FeatureType feature, List<int> allItemIds) async {
    for (final id in allItemIds) {
      final readKey = '$_readItemsPrefix${feature.name}_$id';
      await _prefs.setBool(readKey, true);
    }
  }

  /// Reset tracking for testing (optional - remove in production)
  Future<void> resetFeature(FeatureType feature) async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('$_readItemsPrefix${feature.name}_')) {
        await _prefs.remove(key);
      }
    }
  }
}
