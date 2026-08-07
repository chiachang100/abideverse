import 'bible_translation.dart';
import 'bible_verse.dart';
import 'scripture_reference.dart';

abstract interface class BibleRepository {
  Future<List<BibleTranslation>> getTranslations();
  Future<BibleVerse?> getVerse({
    required String translationId,
    required String bookId,
    required int chapter,
    required int verse,
  });
  Future<List<BibleVerse>> getChapter({
    required String translationId,
    required String bookId,
    required int chapter,
  });
  Future<List<BibleVerse>> getRange({
    required String translationId,
    required ScriptureReference reference,
  });
  Future<List<BibleVerse>> search({
    required String translationId,
    required String query,
    int limit = 20,
  });
}
