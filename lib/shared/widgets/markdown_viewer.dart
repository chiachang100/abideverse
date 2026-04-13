import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownViewer extends StatefulWidget {
  final String assetPath;
  final String title;
  final bool showAppBar;
  final EdgeInsets padding;
  final MarkdownStyleSheet? customStyle;

  const MarkdownViewer({
    super.key,
    required this.assetPath,
    required this.title,
    this.showAppBar = true,
    this.padding = const EdgeInsets.all(16),
    this.customStyle,
  });

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  Future<String>? _markdownFuture;

  @override
  void initState() {
    super.initState();
    _markdownFuture = rootBundle.loadString(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(widget.title), elevation: 0)
          : null,
      body: FutureBuilder<String>(
        future: _markdownFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: widget.padding,
            child: MarkdownBody(
              data: snapshot.data!,
              selectable: true,
              styleSheet:
                  widget.customStyle ?? _buildDefaultMarkdownStyle(context),
              onTapLink: _handleLinkTap,
              imageBuilder: _buildImage,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading content: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _markdownFuture = rootBundle.loadString(widget.assetPath);
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLinkTap(String? text, String? href, String? title) async {
    if (href != null) {
      final uri = Uri.parse(href);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildImage(Uri? uri, String? title, String? alt) {
    if (uri == null) {
      return const Icon(Icons.broken_image, size: 100);
    }

    return Image.network(
      uri.toString(),
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 100);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(height: 100, child: CircularProgressIndicator()),
        );
      },
    );
  }

  MarkdownStyleSheet _buildDefaultMarkdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Safe approach: only use properties that definitely exist
    final baseStyle = MarkdownStyleSheet.fromTheme(theme);

    return baseStyle.copyWith(
      h1: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      h2: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      h3: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      p: textTheme.bodyLarge,
      strong: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      em: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
      blockquote: textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
      a: textTheme.bodyLarge?.copyWith(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      code: textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
