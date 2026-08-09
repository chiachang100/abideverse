import '../../bible/domain/scripture_reference.dart';

class ScriptureReferenceParser {
  static final RegExp _chapterVersePattern = RegExp(
    r'(\d+)\s*:\s*(\d+)(?:\s*[-–]\s*(\d+))?',
  );

  static const Map<String, String> _books = {
    'genesis': 'genesis',
    'gen': 'genesis',

    'exodus': 'exodus',
    'exo': 'exodus',
    'ex': 'exodus',

    'leviticus': 'leviticus',
    'lev': 'leviticus',

    'numbers': 'numbers',
    'num': 'numbers',

    'deuteronomy': 'deuteronomy',
    'deut': 'deuteronomy',
    'deu': 'deuteronomy',

    'joshua': 'joshua',
    'josh': 'joshua',

    'judges': 'judges',
    'judg': 'judges',

    'ruth': 'ruth',

    '1 samuel': '1samuel',
    '1 sam': '1samuel',
    '1sa': '1samuel',

    '2 samuel': '2samuel',
    '2 sam': '2samuel',
    '2sa': '2samuel',

    '1 kings': '1kings',
    '1 king': '1kings',
    '1ki': '1kings',

    '2 kings': '2kings',
    '2 king': '2kings',
    '2ki': '2kings',

    '1 chronicles': '1chronicles',
    '1 chron': '1chronicles',
    '1 chr': '1chronicles',
    '1ch': '1chronicles',

    '2 chronicles': '2chronicles',
    '2 chron': '2chronicles',
    '2 chr': '2chronicles',
    '2ch': '2chronicles',

    'ezra': 'ezra',

    'nehemiah': 'nehemiah',
    'neh': 'nehemiah',

    'esther': 'esther',
    'est': 'esther',

    'job': 'job',

    'psalm': 'psalms',
    'psalms': 'psalms',
    'ps': 'psalms',

    'proverbs': 'proverbs',
    'prov': 'proverbs',
    'pro': 'proverbs',

    'ecclesiastes': 'ecclesiastes',
    'eccl': 'ecclesiastes',

    'song of solomon': 'songofsolomon',
    'song of songs': 'songofsolomon',

    'isaiah': 'isaiah',
    'isa': 'isaiah',

    'jeremiah': 'jeremiah',
    'jer': 'jeremiah',

    'lamentations': 'lamentations',
    'lam': 'lamentations',

    'ezekiel': 'ezekiel',
    'ezek': 'ezekiel',

    'daniel': 'daniel',
    'dan': 'daniel',

    'hosea': 'hosea',
    'hos': 'hosea',

    'joel': 'joel',

    'amos': 'amos',

    'obadiah': 'obadiah',
    'obad': 'obadiah',

    'jonah': 'jonah',
    'jon': 'jonah',

    'micah': 'micah',
    'mic': 'micah',

    'nahum': 'nahum',
    'nah': 'nahum',

    'habakkuk': 'habakkuk',
    'hab': 'habakkuk',

    'zephaniah': 'zephaniah',
    'zeph': 'zephaniah',

    'haggai': 'haggai',
    'hag': 'haggai',

    'zechariah': 'zechariah',
    'zech': 'zechariah',

    'malachi': 'malachi',
    'mal': 'malachi',

    'matthew': 'matthew',
    'matt': 'matthew',
    'mt': 'matthew',

    'mark': 'mark',
    'mk': 'mark',

    'luke': 'luke',
    'lk': 'luke',

    'john': 'john',
    'jn': 'john',

    'acts': 'acts',
    'act': 'acts',

    'romans': 'romans',
    'rom': 'romans',

    '1 corinthians': '1corinthians',
    '1 cor': '1corinthians',
    '1co': '1corinthians',

    '2 corinthians': '2corinthians',
    '2 cor': '2corinthians',
    '2co': '2corinthians',

    'galatians': 'galatians',
    'gal': 'galatians',

    'ephesians': 'ephesians',
    'eph': 'ephesians',

    'philippians': 'philippians',
    'phil': 'philippians',
    'php': 'philippians',

    'colossians': 'colossians',
    'col': 'colossians',

    '1 thessalonians': '1thessalonians',
    '1 thess': '1thessalonians',
    '1th': '1thessalonians',

    '2 thessalonians': '2thessalonians',
    '2 thess': '2thessalonians',
    '2th': '2thessalonians',

    '1 timothy': '1timothy',
    '1 tim': '1timothy',
    '1ti': '1timothy',

    '2 timothy': '2timothy',
    '2 tim': '2timothy',
    '2ti': '2timothy',

    'titus': 'titus',
    'tit': 'titus',

    'philemon': 'philemon',
    'phm': 'philemon',

    'hebrews': 'hebrews',
    'heb': 'hebrews',

    'james': 'james',
    'jas': 'james',

    '1 peter': '1peter',
    '1 pet': '1peter',
    '1pe': '1peter',

    '2 peter': '2peter',
    '2 pet': '2peter',
    '2pe': '2peter',

    '1 john': '1john',
    '1 jn': '1john',
    '1jn': '1john',

    '2 john': '2john',
    '2 jn': '2john',
    '2jn': '2john',

    '3 john': '3john',
    '3 jn': '3john',
    '3jn': '3john',

    'jude': 'jude',

    'revelation': 'revelation',
    'rev': 'revelation',
  };

  ScriptureReference? parse(String input) {
    final match = _chapterVersePattern.firstMatch(input);

    if (match == null) {
      return null;
    }

    final chapter = int.parse(match.group(1)!);
    final startVerse = int.parse(match.group(2)!);
    final endVerse = match.group(3) == null ? null : int.parse(match.group(3)!);

    final beforeReference = input.substring(0, match.start);

    final normalized = beforeReference
        .toLowerCase()
        .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    String? bookId;

    final aliases = _books.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final alias in aliases) {
      if (normalized.endsWith(alias)) {
        bookId = _books[alias];
        break;
      }
    }

    if (bookId == null) {
      return null;
    }

    return ScriptureReference(
      bookId: bookId,
      chapter: chapter,
      startVerse: startVerse,
      endVerse: endVerse,
    );
  }
}
