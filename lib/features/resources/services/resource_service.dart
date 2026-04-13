import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:abideverse/features/resources/models/resource_model.dart';

class ResourceService {
  static final ResourceService _instance = ResourceService._internal();
  factory ResourceService() => _instance;
  ResourceService._internal();

  CollectionReference<ResourceModel> get _resourcesCollection {
    return FirebaseFirestore.instance
        .collection('resources')
        .withConverter<ResourceModel>(
          fromFirestore: (snapshot, _) => ResourceModel.fromFirestore(snapshot),
          toFirestore: (model, _) => model.toFirestore(),
        );
  }

  /// Stream of active resources - automatically caches offline
  Stream<List<ResourceModel>> getActiveResources() {
    return _resourcesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
        .handleError((error) {
          debugPrint('Error loading resources from Firebase: $error');
          // Return empty list on error - UI will show fallback
          return <ResourceModel>[];
        });
  }

  /// Get single resource by ID with local fallback
  Stream<ResourceModel?> getResource(String id) {
    return _resourcesCollection
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.data())
        .handleError((error) {
          debugPrint('Error loading resource $id: $error');
          return null;
        });
  }

  /// Load local asset as fallback (optional)
  Future<ResourceModel?> getLocalResource(String id) async {
    try {
      final assetPath = 'assets/markdown/$id.md';
      final content = await rootBundle.loadString(assetPath);

      // Create a temporary resource model from local asset
      return ResourceModel(
        id: id,
        titleKey:
            'md${id.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join('')}',
        descriptionKey:
            'md${id.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join('')}Desc',
        markdownContent: content,
        iconName: 'library_books',
        colorValue: 0xFF4285F4,
        displayOrder: 0,
        isActive: true,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error loading local resource $id: $e');
      return null;
    }
  }

  /// Check if data is from cache (for UI indicators)
  Future<bool> isFromCache(String resourceId) async {
    try {
      final doc = await _resourcesCollection
          .doc(resourceId)
          .get(const GetOptions(source: Source.cache));
      return doc.exists;
    } catch (e) {
      return true; // Assume cache if error
    }
  }
}
