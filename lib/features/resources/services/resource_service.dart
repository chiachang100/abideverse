import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:abideverse/features/resources/models/resource_model.dart';

class ResourceService {
  final DEBUG_HEADER = "[ResourceService]";
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

  /// Stream of active resources - with local fallback for offline support
  Stream<List<ResourceModel>> getActiveResources() async* {
    // Try to get cached/offline data first
    List<ResourceModel>? cachedResources;
    try {
      final cachedSnapshot = await _resourcesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('displayOrder')
          .get(const GetOptions(source: Source.cache));

      cachedResources = cachedSnapshot.docs.map((doc) => doc.data()).toList();

      if (cachedResources.isNotEmpty) {
        yield cachedResources;
      }
    } catch (e) {
      debugPrint('$DEBUG_HEADER Error loading cached active resources: $e');
    }

    // Then stream real-time updates from Firebase (will use cache if offline)
    await for (var snapshot
        in _resourcesCollection
            .where('isActive', isEqualTo: true)
            .orderBy('displayOrder')
            .snapshots()
            .handleError((error) {
              debugPrint(
                '$DEBUG_HEADER Error loading resources from Firebase: $error',
              );
              return <ResourceModel>[];
            })) {
      final firebaseResources = snapshot.docs.map((doc) => doc.data()).toList();

      // Only yield if different from cached (prevents unnecessary rebuilds)
      if (firebaseResources.isNotEmpty &&
          !_listsAreEqual(cachedResources, firebaseResources)) {
        yield firebaseResources;
        cachedResources = firebaseResources;
      } else if (firebaseResources.isEmpty && cachedResources != null) {
        // Keep yielding cached if Firebase returns empty
        yield cachedResources;
      } else if (firebaseResources.isNotEmpty) {
        yield firebaseResources;
      }
    }
  }

  /// Get single resource by ID with local fallback and real-time updates
  Stream<ResourceModel?> getResource(String id) async* {
    ResourceModel? localResource;

    // 1. Immediately load and yield local asset if available
    try {
      localResource = await getLocalResource(id);
      if (localResource != null) {
        debugPrint('$DEBUG_HEADER Loaded local resource: $id');
        yield localResource;
      }
    } catch (e) {
      debugPrint('$DEBUG_HEADER Error loading local resource $id: $e');
    }

    // 2. Try to get cached Firestore data (fast offline access)
    ResourceModel? cachedResource;
    try {
      final cachedDoc = await _resourcesCollection
          .doc(id)
          .get(const GetOptions(source: Source.cache));

      if (cachedDoc.exists) {
        cachedResource = cachedDoc.data();
        if (cachedResource != null &&
            (localResource == null ||
                cachedResource.updatedAt != localResource.updatedAt)) {
          debugPrint('$DEBUG_HEADER Loaded cached Firestore resource: $id');
          yield cachedResource;
        }
      }
    } catch (e) {
      debugPrint('$DEBUG_HEADER Error loading cached resource $id: $e');
    }

    // 3. Set up real-time listener for Firebase updates
    try {
      await for (var snapshot
          in _resourcesCollection.doc(id).snapshots().handleError((error) {
            debugPrint(
              '$DEBUG_HEADER Error in real-time stream for resource $id: $error',
            );
          })) {
        final firebaseResource = snapshot.data();

        if (firebaseResource != null) {
          // Check if this is newer than what we've shown
          final currentDisplayed = _getMostRecentResource(
            localResource,
            cachedResource,
            firebaseResource,
          );

          if (currentDisplayed == null ||
              firebaseResource.updatedAt != currentDisplayed.updatedAt) {
            debugPrint('$DEBUG_HEADER Yielding updated Firebase resource: $id');
            yield firebaseResource;
          }
        } else if (localResource == null && cachedResource == null) {
          // No resource found anywhere
          yield null;
        }
        // If Firebase returns null but we have local/cached, keep yielding them
        // (no action needed - stream continues)
      }
    } catch (e) {
      debugPrint(
        '$DEBUG_HEADER Failed to establish Firebase stream for $id: $e',
      );
      // If we can't establish stream, just keep yielding what we have
      if (localResource != null) {
        yield localResource;
      } else if (cachedResource != null) {
        yield cachedResource;
      } else {
        yield null;
      }
    }
  }

  /// Load local asset as fallback from bundled markdown files
  Future<ResourceModel?> getLocalResource(String id) async {
    try {
      final assetPath = 'assets/markdown/$id.md';
      final content = await rootBundle.loadString(assetPath);

      // Parse metadata from markdown if needed, or use defaults
      final titleKey = _generateTitleKey(id);
      final descriptionKey = _generateDescriptionKey(id);

      // Try to extract icon from markdown frontmatter if exists
      String iconName = 'library_books';
      int colorValue = 0xFF4285F4;

      // Simple frontmatter parsing if your markdown includes it
      if (content.startsWith('---')) {
        final endOfFrontmatter = content.indexOf('---', 3);
        if (endOfFrontmatter != -1) {
          final frontmatter = content.substring(3, endOfFrontmatter);
          if (frontmatter.contains('icon:')) {
            final iconMatch = RegExp(r'icon:\s*(\w+)').firstMatch(frontmatter);
            iconName = iconMatch?.group(1) ?? iconName;
          }
          if (frontmatter.contains('color:')) {
            final colorMatch = RegExp(
              r'color:\s*(0x[0-9A-F]+)',
            ).firstMatch(frontmatter);
            colorValue =
                int.tryParse(colorMatch?.group(1) ?? '0xFF4285F4') ??
                colorValue;
          }
        }
      }

      return ResourceModel(
        id: id,
        titleKey: titleKey,
        descriptionKey: descriptionKey,
        markdownContent: content,
        iconName: iconName,
        colorValue: colorValue,
        displayOrder: 0,
        isActive: true,
        updatedAt: DateTime.now(),
        // Include any metadata you parsed from markdown
        isLocalOnly: true, // You may want to add this flag to ResourceModel
      );
    } catch (e) {
      debugPrint('$DEBUG_HEADER Error loading local resource $id: $e');
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

  /// Force refresh a resource from server (bypass cache)
  Future<ResourceModel?> refreshResource(String id) async {
    try {
      final doc = await _resourcesCollection
          .doc(id)
          .get(const GetOptions(source: Source.server));
      return doc.data();
    } catch (e) {
      debugPrint('$DEBUG_HEADER Error refreshing resource $id: $e');
      return null;
    }
  }

  // Helper methods
  String _generateTitleKey(String id) {
    // Convert resource_about_us -> mdAboutUs
    final parts = id.split('_');
    final camelCase = parts
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join('');
    return 'md$camelCase';
  }

  String _generateDescriptionKey(String id) {
    return '${_generateTitleKey(id)}Desc';
  }

  ResourceModel? _getMostRecentResource(
    ResourceModel? local,
    ResourceModel? cached,
    ResourceModel? firebase,
  ) {
    final resources = [
      local,
      cached,
      firebase,
    ].whereType<ResourceModel>().toList();

    if (resources.isEmpty) return null;

    resources.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return resources.first;
  }

  bool _listsAreEqual(List<ResourceModel>? a, List<ResourceModel>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].updatedAt != b[i].updatedAt) {
        return false;
      }
    }
    return true;
  }
}
