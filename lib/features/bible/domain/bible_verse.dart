import 'bible_translation.dart';

class BibleVerse {
  final int id;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final BibleTranslation translation;

  const BibleVerse({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.translation,
  });

  String get reference => '$bookName $chapter:$verse';
}
