// test/joystore_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abideverse/app/app.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
// Import your application files
import 'package:abideverse/models/locale_info_model.dart';
import 'package:abideverse/shared/localization/codegen_loader.g.dart';

import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  // Use setUpAll to ensure the initialization only happens once
  setUpAll(() async {
    // 1. Initialize the Flutter Widgets binding for testing
    // This is often required for platform-dependent packages.
    TestWidgetsFlutterBinding.ensureInitialized();

    // 🔥 Fix MissingPluginException for shared_preferences
    SharedPreferences.setMockInitialValues({});

    // Initialize easy_localization
    await EasyLocalization.ensureInitialized();

    // 2. Set the device's preferred locales for the test environment
    // This mocks the platform service that easy_localization calls to get _deviceLocale
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter/localization'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getPreferredLocales') {
            // Provide a fake, non-null response matching one of your supportedLocales
            return <String>['en_US'];
          }
          return null;
        });
  });

  tearDownAll(() async {
    // Runs once after all tests
    print('Test Tearing Down!');
  });

  testWidgets('Joystore renders test', (WidgetTester tester) async {
    // Create an instance of the correctly typed mock
    final MockFirebaseFirestore mockFirestore = MockFirebaseFirestore();

    await tester.runAsync(() async {
      await rootBundle.loadString('assets/translations/en-US.json');
    });

    final Widget testApp = EasyLocalization(
      assetLoader: const CodegenLoader(),

      // Use a single supported locale for simplicity in the test
      supportedLocales: const [Locale('en', 'US')],
      path:
          'assets/translations', // Path is still required, but files won't be loaded
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: false, // Set to false for testing
      child: ChangeNotifierProvider<LocaleInfoModel>(
        create: (_) => LocaleInfoModel(),
        // Wrap your main widget (Joystore) in MaterialApp/CupertinoApp
        // if Joystore itself isn't one.
        child: Builder(
          builder: (context) {
            return MaterialApp(
              home: Joystore(firestore: mockFirestore),
              // Set localization delegates required by EasyLocalization
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            );
          },
        ),
      ),
    );

    // 2. Build the app using the wrapper widget
    await tester.pumpWidget(testApp);

    // 3. Start your assertions and interactions

    // Trivial assertion that is always true
    expect(true, isTrue);
  });

  test('This test always passes', () {
    // A trivial assertion that is always true
    expect(1 + 1, equals(2));
  });

  test('Always true test', () {
    expect(true, isTrue);
  });

  test('Always passes with equality', () {
    expect('hello', equals('hello'));
  });
}
