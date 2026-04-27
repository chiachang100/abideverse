import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

enum FeatureType { joys, scriptures, treasures }

final logger = Logger('NewItemTracker');

class NewItemTracker {
  static const String _readItemsKey = 'read_items_';

  // Use a Set for O(1) lookups instead of List
  final Map<FeatureType, Set<int>> _readItemsCache = {};

  static final NewItemTracker _instance = NewItemTracker._internal();
  factory NewItemTracker() => _instance;
  NewItemTracker._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance._prefs = prefs;
    await _instance._loadAllReadItems();
    _instance._isInitialized = true;
  }

  /// Load all read items into memory cache
  Future<void> _loadAllReadItems() async {
    for (final feature in FeatureType.values) {
      final key = '$_readItemsKey${feature.name}';
      final List<String>? savedList = _prefs.getStringList(key);

      if (savedList != null) {
        _readItemsCache[feature] = savedList.map(int.parse).toSet();
      } else {
        _readItemsCache[feature] = {};
      }
    }
  }

  /// Save a feature's read items to SharedPreferences
  Future<void> _saveFeatureReadItems(FeatureType feature) async {
    final key = '$_readItemsKey${feature.name}';
    final List<String> listToSave = _readItemsCache[feature]!
        .map((id) => id.toString())
        .toList();
    await _prefs.setStringList(key, listToSave);
  }

  /// Check if an item should show "NEW" badge
  Future<bool> isItemNew(
    FeatureType feature,
    int itemId,
    bool isNewFlag,
  ) async {
    if (!_isInitialized) await init();

    logger.fine('📊 TRACKER CALL: id=$itemId, isNewFlag=$isNewFlag');

    if (!isNewFlag) {
      logger.fine('⏭️ RETURNING FALSE because isNewFlag=false');
      return false;
    }

    final isRead = _readItemsCache[feature]?.contains(itemId) ?? false;
    final result = !isRead;

    logger.fine(
      '✅ feature=${feature.name}, id=$itemId, isRead=$isRead, result=$result',
    );
    return result;
  }

  /// Synchronous version for performance (use with cached data)
  bool isItemNewSync(FeatureType feature, int itemId, bool isNewFlag) {
    if (!isNewFlag) return false;
    return !(_readItemsCache[feature]?.contains(itemId) ?? false);
  }

  /// Mark item as read (when user taps)
  Future<void> markItemAsRead(FeatureType feature, int itemId) async {
    if (!_isInitialized) await init();

    final readSet = _readItemsCache[feature];
    if (readSet != null && !readSet.contains(itemId)) {
      readSet.add(itemId);
      await _saveFeatureReadItems(feature);
    }
  }

  /// Mark multiple items as read in batch
  Future<void> markMultipleAsRead(
    FeatureType feature,
    List<int> itemIds,
  ) async {
    if (!_isInitialized) await init();

    final readSet = _readItemsCache[feature];
    if (readSet != null) {
      bool hasChanges = false;
      for (final id in itemIds) {
        if (readSet.add(id)) {
          hasChanges = true;
        }
      }
      if (hasChanges) {
        await _saveFeatureReadItems(feature);
      }
    }
  }

  /// Get count of new (unread) items - OPTIMIZED
  Future<int> getNewItemsCount<T>(
    FeatureType feature,
    List<T> items,
    bool Function(T item) getIsNewFlag,
    int Function(T item) getId,
  ) async {
    if (!_isInitialized) await init();

    final readSet = _readItemsCache[feature] ?? {};
    int count = 0;

    for (final item in items) {
      if (getIsNewFlag(item) && !readSet.contains(getId(item))) {
        count++;
      }
    }
    return count;
  }

  /// Get count of new items using cached data (synchronous)
  int getNewItemsCountSync<T>(
    FeatureType feature,
    List<T> items,
    bool Function(T item) getIsNewFlag,
    int Function(T item) getId,
  ) {
    final readSet = _readItemsCache[feature] ?? {};
    int count = 0;

    for (final item in items) {
      if (getIsNewFlag(item) && !readSet.contains(getId(item))) {
        count++;
      }
    }
    return count;
  }

  /// Mark ALL items as read for a feature
  Future<void> markAllAsRead(FeatureType feature, List<int> allItemIds) async {
    if (!_isInitialized) await init();

    final readSet = _readItemsCache[feature];
    if (readSet != null) {
      // Add all IDs at once
      readSet.addAll(allItemIds);
      await _saveFeatureReadItems(feature);
    }
  }

  /// Mark ALL items as read (all features)
  Future<void> markAllFeaturesAsRead() async {
    if (!_isInitialized) await init();

    for (final feature in FeatureType.values) {
      final readSet = _readItemsCache[feature];
      if (readSet != null) {
        // Clear means all are read? Or we need all item IDs
        // For "mark all as read" without IDs, we'd need to know all possible IDs
        // Alternative: Store a timestamp of last "mark all" action
        logger.warning(
          'markAllFeaturesAsRead requires item IDs for each feature',
        );
      }
    }
  }

  /// Alternative: Use timestamp-based "read since" approach
  Future<void> markAllAsReadSince(FeatureType feature, DateTime since) async {
    final key = '$_readItemsKey${feature.name}_last_read_timestamp';
    await _prefs.setString(key, since.toIso8601String());
  }

  /// Check if item is new based on timestamp
  Future<bool> isItemNewByTimestamp(
    FeatureType feature,
    DateTime itemCreatedDate,
  ) async {
    final key = '$_readItemsKey${feature.name}_last_read_timestamp';
    final lastReadStr = _prefs.getString(key);

    if (lastReadStr == null) return true;

    final lastRead = DateTime.parse(lastReadStr);
    return itemCreatedDate.isAfter(lastRead);
  }

  /// Get total number of read items (for debugging)
  int getReadItemsCount(FeatureType feature) {
    return _readItemsCache[feature]?.length ?? 0;
  }

  /// Reset tracking for testing
  Future<void> resetFeature(FeatureType feature) async {
    if (!_isInitialized) await init();

    _readItemsCache[feature] = {};
    await _saveFeatureReadItems(feature);
  }

  /// Clear all read items (use with caution!)
  Future<void> clearAllReadItems() async {
    // if (!_isInitialized) await init();

    for (final feature in FeatureType.values) {
      // _readItemsCache[feature] = {};
      // await _saveFeatureReadItems(feature);

      resetFeature(feature);
    }
  }
}
