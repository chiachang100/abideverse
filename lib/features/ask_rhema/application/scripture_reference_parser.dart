import '../../bible/domain/scripture_reference.dart';

class ScriptureReferenceParser {
  static final RegExp _chapterVersePattern = RegExp(
    r'(\d+)\s*:\s*(\d+)(?:\s*[-–]\s*(\d+))?',
  );

  static final RegExp _chapterOnlyPattern = RegExp(
    r'(?:\bchapter\s+)?(\d+)\s*$',
    caseSensitive: false,
  );

  static const Map<String, String> _books = {
    'genesis': 'genesis',
    'gen': 'genesis',
    'exodus': 'exodus',
    'exo': 'exodus',
    'leviticus': 'leviticus',
    'lev': 'leviticus',
    'numbers': 'numbers',
    'num': 'numbers',
    'deuteronomy': 'deuteronomy',
    'deut': 'deuteronomy',
    'joshua': 'joshua',
    'judges': 'judges',
    'ruth': 'ruth',

    '1 samuel': '1samuel',
    '1 sam': '1samuel',
    '2 samuel': '2samuel',
    '2 sam': '2samuel',

    '1 kings': '1kings',
    '2 kings': '2kings',

    '1 chronicles': '1chronicles',
    '2 chronicles': '2chronicles',

    'ezra': 'ezra',
    'nehemiah': 'nehemiah',
    'esther': 'esther',
    'job': 'job',
    'psalm': 'psalms',
    'psalms': 'psalms',
    'proverbs': 'proverbs',
    'ecclesiastes': 'ecclesiastes',
    'song of solomon': 'songofsolomon',
    'song of songs': 'songofsolomon',
    'isaiah': 'isaiah',
    'jeremiah': 'jeremiah',
    'lamentations': 'lamentations',
    'ezekiel': 'ezekiel',
    'daniel': 'daniel',
    'hosea': 'hosea',
    'joel': 'joel',
    'amos': 'amos',
    'obadiah': 'obadiah',
    'jonah': 'jonah',
    'micah': 'micah',
    'nahum': 'nahum',
    'habakkuk': 'habakkuk',
    'zephaniah': 'zephaniah',
    'haggai': 'haggai',
    'zechariah': 'zechariah',
    'malachi': 'malachi',

    'matthew': 'matthew',
    'mark': 'mark',
    'luke': 'luke',
    'john': 'john',
    'acts': 'acts',
    'romans': 'romans',

    '1 corinthians': '1corinthians',
    '2 corinthians': '2corinthians',
    'galatians': 'galatians',
    'ephesians': 'ephesians',
    'philippians': 'philippians',
    'colossians': 'colossians',

    '1 thessalonians': '1thessalonians',
    '2 thessalonians': '2thessalonians',
    '1 timothy': '1timothy',
    '2 timothy': '2timothy',
    'titus': 'titus',
    'philemon': 'philemon',
    'hebrews': 'hebrews',
    'james': 'james',

    '1 peter': '1peter',
    '2 peter': '2peter',
    '1 john': '1john',
    '2 john': '2john',
    '3 john': '3john',

    'jude': 'jude',
    'revelation': 'revelation',
  };

  ScriptureReference? parse(String input) {
    final normalizedInput = _normalizeInput(input);

    // ---------------------------------------------------------------
    // Verse reference:
    //
    // Romans 8:28
    // What does Romans 8:28 mean?
    // Explain Romans 8:28-30.
    // 1 Corinthians 13:4-7
    // ---------------------------------------------------------------

    final verseMatch = _chapterVersePattern.firstMatch(normalizedInput);

    if (verseMatch != null) {
      final bookId = _findBookId(
        normalizedInput.substring(0, verseMatch.start),
      );

      if (bookId == null) {
        return null;
      }

      return ScriptureReference(
        bookId: bookId,
        chapter: int.parse(verseMatch.group(1)!),
        startVerse: int.parse(verseMatch.group(2)!),
        endVerse: verseMatch.group(3) == null
            ? null
            : int.parse(verseMatch.group(3)!),
      );
    }

    // ---------------------------------------------------------------
    // Chapter-only reference:
    //
    // John 15
    // John chapter 15
    // Explain the context of John 15
    // Explain the context of John chapter 15
    // ---------------------------------------------------------------

    final chapterMatch = _chapterOnlyPattern.firstMatch(normalizedInput);

    if (chapterMatch == null) {
      return null;
    }

    final chapter = int.parse(chapterMatch.group(1)!);

    var beforeChapter = normalizedInput.substring(0, chapterMatch.start);

    // Remove "chapter" immediately before the number.
    beforeChapter = beforeChapter.replaceFirst(
      RegExp(r'\bchapter\s*$', caseSensitive: false),
      '',
    );

    final bookId = _findBookId(beforeChapter);

    if (bookId == null) {
      return null;
    }

    return ScriptureReference(
      bookId: bookId,
      chapter: int.parse(chapterMatch.group(1)!),
    );
  }

  String _normalizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _findBookId(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final aliases = _books.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final alias in aliases) {
      if (normalized.endsWith(alias)) {
        return _books[alias];
      }
    }

    return null;
  }
}
