import '../../bible/domain/bible_repository.dart';
import '../../bible/domain/bible_verse.dart';
import '../domain/ask_rhema_request.dart';
import '../domain/ask_rhema_response.dart';
import '../domain/ask_rhema_service.dart';
import '../../../shared/services/ai/ai_service.dart';
import '../application/scripture_reference_parser.dart';

class AskRhemaServiceImpl implements AskRhemaService {
  AskRhemaServiceImpl({
    required BibleRepository bibleRepository,
    required AIService aiService,
  }) : _bibleRepository = bibleRepository,
       _aiService = aiService;

  final BibleRepository _bibleRepository;
  final AIService _aiService;

  final ScriptureReferenceParser _referenceParser = ScriptureReferenceParser();

  @override
  Future<AskRhemaResponse> ask(AskRhemaRequest request) async {
    final sources = await _findSources(request);

    final prompt = _buildPrompt(request: request, sources: sources);

    final answer = await _aiService.generateText(prompt);

    return AskRhemaResponse(answer: answer ?? '', sources: sources);
  }

  String _buildSearchQuery(String question) {
    final stopWords = {
      'what',
      'does',
      'do',
      'the',
      'a',
      'an',
      'is',
      'are',
      'about',
      'how',
      'why',
      'can',
      'could',
      'would',
      'should',
      'scripture',
      'say',
      'says',
      'tell',
      'me',
      'explain',
      'context',
      'of',
      'toward',
      'towards',
      'in',
      'on',
      'for',
      'to',
      'and',
      'or',
      'with',
    };

    final words = question
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 3)
        .where((word) => !stopWords.contains(word))
        .toList();

    return words.join(' ');
  }

  Future<List<BibleVerse>> _findSources(AskRhemaRequest request) async {
    final reference = _referenceParser.parse(request.question);

    // Specific reference: John 15:16
    if (reference != null && reference.startVerse != null) {
      if (reference.endVerse != null) {
        return _bibleRepository.getRange(
          translationId: request.translationId,
          reference: reference,
        );
      }

      final verse = await _bibleRepository.getVerse(
        translationId: request.translationId,
        bookId: reference.bookId,
        chapter: reference.chapter,
        verse: reference.startVerse!,
      );

      return verse == null ? <BibleVerse>[] : [verse];
    }

    // Chapter reference: John 15 / John chapter 15
    if (reference != null && reference.startVerse == null) {
      return _bibleRepository.getChapter(
        translationId: request.translationId,
        bookId: reference.bookId,
        chapter: reference.chapter,
      );
    }

    // General theological question:
    // "What does Scripture say about forgiveness?"
    // "How does the Old Testament point toward Christ?"
    return _bibleRepository.search(
      translationId: request.translationId,
      query: request.question,
      limit: 8,
    );
  }

  String _buildPrompt({
    required AskRhemaRequest request,
    required List<BibleVerse> sources,
  }) {
    final scriptureContext = sources.isEmpty
        ? 'No Scripture passages were found.'
        : sources
              .map((verse) => '[${verse.reference}]\n${verse.text}')
              .join('\n\n');

    final history = request.history
        .map((message) => '${message.role.name}: ${message.text}')
        .join('\n');

    return '''
You are AskRhema, an AI Bible companion.

Answer the user's question using the supplied Scripture passages.

Rules:

1. Do not invent Scripture references.
2. Clearly distinguish Scripture from interpretation.
3. If the supplied passages are insufficient, say so.
4. Respect the selected Bible translation.
5. Answer in the user's language.
6. Do not claim divine revelation or speak as though you are God.
7. Encourage the user toward Scripture and thoughtful reflection.
8. If the user asks about a specific Scripture reference, prioritize the supplied passage for that reference.
9. Do not substitute another passage for the requested Scripture reference.
10. When the supplied passages cover an entire chapter, use the chapter context when answering questions about that chapter.

SCRIPTURE SOURCES:

$scriptureContext

CONVERSATION:

$history

USER QUESTION:

${request.question}
''';
  }
}
