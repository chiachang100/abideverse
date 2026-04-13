import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abideverse/features/resources/services/resource_service.dart';
import 'package:abideverse/features/resources/models/resource_model.dart';

// Service provider
final resourceServiceProvider = Provider<ResourceService>((ref) {
  return ResourceService();
});

// Stream of all active resources (auto-cached by Firestore)
final resourcesStreamProvider = StreamProvider<List<ResourceModel>>((ref) {
  final service = ref.watch(resourceServiceProvider);
  return service.getActiveResources();
});

// Individual resource provider
final resourceProvider = StreamProvider.family<ResourceModel?, String>((
  ref,
  id,
) {
  final service = ref.watch(resourceServiceProvider);
  return service.getResource(id);
});
