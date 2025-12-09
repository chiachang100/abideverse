// lib/startup/startup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:abideverse/startup/app_initializer.dart';
import 'package:abideverse/app/app.dart'; // Joystore
import 'package:abideverse/core/constants/locale_constants.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await AppInitializer.initialize();

      // Set EasyLocalization's runtime locale based on LocaleConstants.
      // LocaleConstants.currentLocale stores a string like 'zh-TW' (matching your existing constants).
      // Convert to a Locale object. Adjust parsing if your constant format differs.
      final parts = LocaleConstants.currentLocale.split('-');
      Locale newLocale;
      if (parts.length == 2) {
        newLocale = Locale(parts[0], parts[1]);
      } else {
        newLocale = Locale(parts[0]);
      }

      // update the app locale (safe: we are inside a widget context)
      await context.setLocale(newLocale);

      // Remove the native splash AFTER expensive initialization completes.
      FlutterNativeSplash.remove();

      // Navigate to the real app (Joystore expects a firestore instance)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Joystore(firestore: FirebaseFirestore.instance),
        ),
      );
    } catch (e, st) {
      // If initialization fails, remove splash and show a simple error screen.
      FlutterNativeSplash.remove();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => _StartupErrorScreen(error: e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final String error;
  const _StartupErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initialization Error')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Startup failed: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StartupScreen()),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
