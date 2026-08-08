import 'package:sqlite3/common.dart';

import '../domain/bible_repository.dart';
import '../domain/bible_translation.dart';
import '../domain/bible_verse.dart';
import '../domain/scripture_reference.dart';
import 'bible_database.dart';

class SqliteBibleRepository implements BibleRepository {
  SqliteBibleRepository({required BibleDatabase database})
    : _db = database.database;

  final CommonDatabase _db;

  String _column(String id) => switch (id) {
    'web' => 'web',
    'cuv_hant' => 'cuv_hant',
    'cuv_hans' => 'cuv_hans',
    _ => throw ArgumentError('Unsupported translation: $id'),
  };

  String _bookName(dynamic row, String translationId) =>
      switch (translationId) {
        'cuv_hant' => row['name_zh_hant'] as String,
        'cuv_hans' => row['name_zh_hans'] as String,
        _ => row['name_en'] as String,
      };

  BibleVerse _map(dynamic row, String translationId) {
    return BibleVerse(
      id: row['id'] as int,
      bookId: row['book_id'] as String,
      bookName: _bookName(row, translationId),
      chapter: row['chapter'] as int,
      verse: row['verse'] as int,
      text: row['text'] as String,
      translation: BibleTranslation(
        id: translationId,
        name: row['translation_name'] as String,
        languageCode: row['language_code'] as String,
      ),
    );
  }

  String _select(String translationId) {
    final column = _column(translationId);

    return '''
      SELECT
        v.id,
        v.book_id,
        b.name_en,
        b.name_zh_hant,
        b.name_zh_hans,
        v.chapter,
        v.verse,
        v.$column AS text,
        t.id AS translation_id,
        t.name AS translation_name,
        t.language_code
      FROM verses v
      JOIN books b ON b.id = v.book_id
      JOIN translations t ON t.id = ?
    ''';
  }

  @override
  Future<List<BibleTranslation>> getTranslations() async {
    final rows = _db.select('''
      SELECT id, name, language_code
      FROM translations
      ORDER BY id
      ''');

    return rows
        .map(
          (row) => BibleTranslation(
            id: row['id'] as String,
            name: row['name'] as String,
            languageCode: row['language_code'] as String,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<BibleVerse?> getVerse({
    required String translationId,
    required String bookId,
    required int chapter,
    required int verse,
  }) async {
    final rows = _db.select(
      '''
      ${_select(translationId)}
      WHERE v.book_id = ?
        AND v.chapter = ?
        AND v.verse = ?
      LIMIT 1
      ''',
      [translationId, bookId, chapter, verse],
    );

    return rows.isEmpty ? null : _map(rows.first, translationId);
  }

  @override
  Future<List<BibleVerse>> getChapter({
    required String translationId,
    required String bookId,
    required int chapter,
  }) async {
    final rows = _db.select(
      '''
      ${_select(translationId)}
      WHERE v.book_id = ?
        AND v.chapter = ?
      ORDER BY v.verse
      ''',
      [translationId, bookId, chapter],
    );

    return rows.map((row) => _map(row, translationId)).toList(growable: false);
  }

  @override
  Future<List<BibleVerse>> getRange({
    required String translationId,
    required ScriptureReference reference,
  }) async {
    final endVerse = reference.endVerse ?? reference.startVerse;

    final rows = _db.select(
      '''
      ${_select(translationId)}
      WHERE v.book_id = ?
        AND v.chapter = ?
        AND v.verse BETWEEN ? AND ?
      ORDER BY v.verse
      ''',
      [
        translationId,
        reference.bookId,
        reference.chapter,
        reference.startVerse,
        endVerse,
      ],
    );

    return rows.map((row) => _map(row, translationId)).toList(growable: false);
  }

  @override
  Future<List<BibleVerse>> search({
    required String translationId,
    required String query,
    int limit = 20,
  }) async {
    final normalized = query.trim();

    if (normalized.isEmpty || limit <= 0) {
      return const [];
    }

    final table = translationId == 'web' ? 'verses_fts_en' : 'verses_fts_zh';

    final baseSql = _select(translationId);

    // First try FTS5.
    final ftsRows = _db.select(
      '''
    $baseSql
    JOIN $table f ON f.verse_id = v.id
    WHERE t.id = ?
      AND f.text MATCH ?
    LIMIT ?
    ''',
      [translationId, translationId, normalized, limit],
    );

    if (ftsRows.isNotEmpty) {
      return ftsRows
          .map((row) => _map(row, translationId))
          .toList(growable: false);
    }

    // Chinese fallback.
    //
    // This is particularly useful for short Chinese queries
    // that cannot form a complete trigram.
    if (translationId != 'web') {
      final column = _column(translationId);

      final likeRows = _db.select(
        '''
    $baseSql
    WHERE t.id = ?
      AND v.$column LIKE ?
    LIMIT ?
    ''',
        [translationId, translationId, '%$normalized%', limit],
      );

      return likeRows
          .map((row) => _map(row, translationId))
          .toList(growable: false);
    }

    return const [];
  }
}
