import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:abideverse/features/bible/data/bible_database.dart';
import 'package:abideverse/features/bible/data/sqlite_bible_repository.dart';
import 'package:abideverse/features/bible/domain/scripture_reference.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BibleDatabase database;
  late SqliteBibleRepository repository;
  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'abideverse_bible_test_',
    );

    database = await BibleDatabase.open(directory: tempDirectory);

    repository = SqliteBibleRepository(database: database);
  });

  tearDownAll(() {
    database.dispose();

    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  group('translations', () {
    test('contains all three translations', () async {
      final translations = await repository.getTranslations();

      final ids = translations.map((t) => t.id).toSet();

      expect(ids, contains('web'));
      expect(ids, contains('cuv_hant'));
      expect(ids, contains('cuv_hans'));
    });
  });

  group('getVerse', () {
    test('gets Genesis 1:1 in WEB', () async {
      final verse = await repository.getVerse(
        translationId: 'web',
        bookId: 'genesis',
        chapter: 1,
        verse: 1,
      );

      expect(verse, isNotNull);
      expect(verse!.reference, 'Genesis 1:1');
      expect(verse.text, isNotEmpty);
      expect(verse.translation.id, 'web');
    });

    test('gets John 3:16 in Traditional Chinese', () async {
      final verse = await repository.getVerse(
        translationId: 'cuv_hant',
        bookId: 'john',
        chapter: 3,
        verse: 16,
      );

      expect(verse, isNotNull);
      expect(verse!.text, isNotEmpty);
      expect(verse.translation.id, 'cuv_hant');
    });

    test('gets John 3:16 in Simplified Chinese', () async {
      final verse = await repository.getVerse(
        translationId: 'cuv_hans',
        bookId: 'john',
        chapter: 3,
        verse: 16,
      );

      expect(verse, isNotNull);
      expect(verse!.text, isNotEmpty);
      expect(verse.translation.id, 'cuv_hans');
    });

    test('returns null for nonexistent verse', () async {
      final verse = await repository.getVerse(
        translationId: 'web',
        bookId: 'john',
        chapter: 999,
        verse: 999,
      );

      expect(verse, isNull);
    });
  });

  group('getChapter', () {
    test('gets Psalm 23', () async {
      final verses = await repository.getChapter(
        translationId: 'web',
        bookId: 'psalms',
        chapter: 23,
      );

      expect(verses, isNotEmpty);
      expect(verses.first.chapter, 23);
      expect(verses.first.verse, 1);
      expect(verses.last.chapter, 23);
    });
  });

  group('getRange', () {
    test('gets Psalm 23:1-6', () async {
      final verses = await repository.getRange(
        translationId: 'web',
        reference: const ScriptureReference(
          bookId: 'psalms',
          chapter: 23,
          startVerse: 1,
          endVerse: 6,
        ),
      );

      expect(verses.length, 6);
      expect(verses.first.verse, 1);
      expect(verses.last.verse, 6);
    });
  });

  group('search', () {
    test('searches English Bible text', () async {
      final results = await repository.search(
        translationId: 'web',
        query: 'faith',
        limit: 10,
      );

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(10));
      expect(results.every((v) => v.translation.id == 'web'), isTrue);
    });

    test('searches Traditional Chinese Bible text', () async {
      final results = await repository.search(
        translationId: 'cuv_hant',
        query: '耶穌',
        limit: 10,
      );

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(10));
      expect(results.every((v) => v.translation.id == 'cuv_hant'), isTrue);
    });

    test('searches Simplified Chinese Bible text', () async {
      final results = await repository.search(
        translationId: 'cuv_hans',
        query: '耶稣',
        limit: 10,
      );

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(10));
      expect(results.every((v) => v.translation.id == 'cuv_hans'), isTrue);
    });

    test('empty search returns no results', () async {
      final results = await repository.search(translationId: 'web', query: '');

      expect(results, isEmpty);
    });
  });
}
