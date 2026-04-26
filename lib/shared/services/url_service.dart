import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlService {
  /// The single source of truth for launching any external URL
  static Future<void> launch(
    String urlString, {
    //LaunchMode mode = LaunchMode.externalApplication,
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final Uri? url = Uri.tryParse(urlString);

    if (url == null) {
      debugPrint('UrlService: Could not parse URL: $urlString');
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: mode, webOnlyWindowName: '_self');
      } else {
        debugPrint('UrlService: Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('UrlService: Exception launching $urlString: $e');
    }
  }
}
