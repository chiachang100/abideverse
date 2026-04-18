import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/app/router.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';
import 'package:abideverse/shared/widgets/markdown_viewer.dart';
import 'package:abideverse/features/resources/models/resource_model.dart';
import 'package:abideverse/features/resources/services/resource_service.dart';

// Provider for ResourceService
final resourceServiceProvider = Provider<ResourceService>((ref) {
  return ResourceService();
});

// Stream provider for resources
final resourcesStreamProvider = StreamProvider<List<ResourceModel>>((ref) {
  final service = ref.watch(resourceServiceProvider);
  return service.getActiveResources();
});

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.resources.tr()),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/icons/abideverse-leading-icon.webp'),
              onPressed: () {
                // Navigate to the joys list
                Routes(context).goJoys();
              },
            );
          },
        ),
      ),
      body: resourcesAsync.when(
        data: (resources) {
          if (resources.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return _buildResourceCard(context, resource: resource);
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading resources...'),
            ],
          ),
        ),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required ResourceModel resource,
  }) {
    final color = Color(resource.colorValue);
    final iconData = _getIconData(resource.iconName);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconData, color: color),
        ),
        title: Text(
          resource.titleKey.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(resource.descriptionKey.tr()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarkdownViewer(
                // Priority 1: Use Firebase content
                markdownContent: resource.markdownContent,
                title: resource.titleKey.tr(),
                resourceId: resource.id,
                // Priority 2: Local asset as fallback (if Firebase fails)
                assetPath: 'assets/markdown/${resource.id}.md',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No resources available',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading resources',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // You could add retry logic here
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'stars':
        return Icons.stars;
      case 'info_outline':
        return Icons.info_outline;
      case 'favorite_outline':
        return Icons.favorite_outline;
      case 'book_outlined':
        return Icons.book_outlined;
      case 'code':
        return Icons.code;
      case 'library_books':
        return Icons.library_books;
      default:
        return Icons.library_books;
    }
  }
}
