import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:abideverse/startup/startup_screen.dart';

class AbideVerseRoot extends StatelessWidget {
  const AbideVerseRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbideVerse',
      debugShowCheckedModeBanner: false,

      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      // Startup flow happens here
      home: StartupScreen(),
    );
  }
}
