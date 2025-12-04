import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:abideverse/shared/services/db/local_storage_service.dart';

void main() {
  late LocalStorageService storage;

  setUp(() {
    // Reset mock storage before each test
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService.instance;
  });

  group('LocalStorageService - String operations', () {
    test('saveString & getString work correctly', () async {
      await storage.saveString(key: 'username', value: 'john');
      final result = await storage.getString(key: 'username', defaultValue: '');

      expect(result, equals('john'));
    });

    test('getString returns null when key does not exist', () async {
      final result = await storage.getString(
        key: 'nonexistent',
        defaultValue: '',
      );
      expect(result, isEmpty);
    });
  });

  group('LocalStorageService - JSON operations', () {
    test('saveJson & getJson work correctly', () async {
      final data = {'verse': 'John 3:16', 'favorite': true};

      await storage.saveJson(key: 'verseData', data: data);
      final result = await storage.getJson(key: 'verseData');

      expect(result, isNotNull);
      expect(result!['verse'], equals('John 3:16'));
      expect(result['favorite'], isTrue);
    });

    test('getJson returns null if key does not exist', () async {
      final result = await storage.getJson(key: 'missing');
      expect(result, isNull);
    });
  });

  group('LocalStorageService - remove operations', () {
    test('removeKey deletes the value', () async {
      await storage.saveString(key: 'token', value: 'abc123');

      await storage.removeKey(key: 'token');
      final result = await storage.getString(key: 'token', defaultValue: '');

      expect(result, isEmpty);
    });
  });

  group('LocalStorageService - existence checks', () {
    test('hasKey returns true when key exists', () async {
      await storage.saveString(key: 'theme', value: 'dark');

      final exists = await storage.hasKey(key: 'theme');
      expect(exists, isTrue);
    });

    test('hasKey returns false when key does NOT exist', () async {
      final exists = await storage.hasKey(key: 'unknown_key');
      expect(exists, isFalse);
    });
  });
}
