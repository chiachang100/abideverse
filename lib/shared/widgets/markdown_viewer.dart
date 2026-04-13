import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownViewer extends StatefulWidget {
  // For local asset files (old way)
  final String? assetPath;

  // For Firebase content (new way)
  final String? markdownContent;

  final String title;
  final String? resourceId;

  const MarkdownViewer({
    super.key,
    this.assetPath,
    this.markdownContent,
    required this.title,
    this.resourceId,
  });

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  String _content = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void didUpdateWidget(MarkdownViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.markdownContent != widget.markdownContent) {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String content = '';

      // Priority 1: Direct markdown content (from Firebase)
      if (widget.markdownContent != null &&
          widget.markdownContent!.isNotEmpty) {
        content = widget.markdownContent!;
      }
      // Priority 2: Local asset file (fallback)
      else if (widget.assetPath != null && widget.assetPath!.isNotEmpty) {
        content = await DefaultAssetBundle.of(
          context,
        ).loadString(widget.assetPath!);
      }
      // No content available
      else {
        _error = 'No content available';
      }

      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading content: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading content...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadContent, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_content.isEmpty) {
      return const Center(child: Text('No content available'));
    }

    // Use MarkdownBody (not MarkdownPlusBody) - this is the correct widget name
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MarkdownBody(data: _content, selectable: true),
    );
  }
}
