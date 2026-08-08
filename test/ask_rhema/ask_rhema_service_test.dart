import 'package:flutter_test/flutter_test.dart';

import 'package:abideverse/features/ask_rhema/data/ask_rhema_service_impl.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_message.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_request.dart';
import 'package:abideverse/features/ask_rhema/domain/ask_rhema_service.dart';
import 'package:abideverse/features/bible/domain/bible_repository.dart';
import 'package:abideverse/features/bible/domain/bible_translation.dart';
import 'package:abideverse/features/bible/domain/bible_verse.dart';
import 'package:abideverse/features/bible/domain/scripture_reference.dart';
import 'package:abideverse/shared/services/ai/ai_service.dart';

void main() {
  late FakeBibleRepository bibleRepository;
  late FakeAIService aiService;
  late AskRhemaService service;

  setUp(() {
    bibleRepository = FakeBibleRepository();
    aiService = FakeAIService();

    service = AskRhemaServiceImpl(
      bibleRepository: bibleRepository,
      aiService: aiService,
    );
  });

  test('searches Bible and returns grounded response', () async {
    bibleRepository.searchResults = [
      BibleVerse(
        id: 1,
        bookId: 'john',
        bookName: 'John',
        chapter: 3,
        verse: 16,
        text: 'For God so loved the world...',
        translation: const BibleTranslation(
          id: 'web',
          name: 'World English Bible',
          languageCode: 'en',
        ),
      ),
    ];

    aiService.response = 'God demonstrates His love through Jesus.';

    final response = await service.ask(
      const AskRhemaRequest(
        question: 'What does God say about His love?',
        translationId: 'web',
      ),
    );

    expect(bibleRepository.lastQuery, 'What does God say about His love?');
    expect(bibleRepository.lastTranslationId, 'web');
    expect(bibleRepository.lastLimit, 8);

    expect(aiService.lastPrompt, contains('John 3:16'));

    expect(aiService.lastPrompt, contains('For God so loved the world...'));

    expect(response.answer, 'God demonstrates His love through Jesus.');

    expect(response.sources, hasLength(1));
    expect(response.sources.first.reference, 'John 3:16');
  });

  test('returns empty sources when Bible search finds nothing', () async {
    bibleRepository.searchResults = [];
    aiService.response = 'I could not find a directly relevant passage.';

    final response = await service.ask(
      const AskRhemaRequest(
        question: 'A question with no matching passage',
        translationId: 'web',
      ),
    );

    expect(response.sources, isEmpty);
    expect(aiService.lastPrompt, contains('No Scripture passages were found.'));
  });

  test('preserves conversation history in prompt', () async {
    bibleRepository.searchResults = [];
    aiService.response = 'Test answer';

    await service.ask(
      const AskRhemaRequest(
        question: 'What about forgiveness?',
        translationId: 'web',
        history: [
          AskRhemaMessage(
            role: AskRhemaRole.user,
            text: 'What does the Bible teach about grace?',
          ),
          AskRhemaMessage(
            role: AskRhemaRole.assistant,
            text: 'The Bible teaches that grace is a gift from God.',
          ),
        ],
      ),
    );

    expect(
      aiService.lastPrompt,
      contains('What does the Bible teach about grace?'),
    );

    expect(
      aiService.lastPrompt,
      contains('The Bible teaches that grace is a gift from God.'),
    );
  });
}

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeAIService implements AIService {
  String response = '';
  String lastPrompt = '';

  @override
  Future<String?> generateText(String prompt) async {
    lastPrompt = prompt;
    return response;
  }
}

class FakeBibleRepository implements BibleRepository {
  List<BibleVerse> searchResults = [];

  String? lastTranslationId;
  String? lastQuery;
  int? lastLimit;

  @override
  Future<List<BibleVerse>> search({
    required String translationId,
    required String query,
    int limit = 20,
  }) async {
    lastTranslationId = translationId;
    lastQuery = query;
    lastLimit = limit;

    return searchResults;
  }

  @override
  Future<List<BibleTranslation>> getTranslations() async {
    return const [];
  }

  @override
  Future<BibleVerse?> getVerse({
    required String translationId,
    required String bookId,
    required int chapter,
    required int verse,
  }) async {
    return null;
  }

  @override
  Future<List<BibleVerse>> getChapter({
    required String translationId,
    required String bookId,
    required int chapter,
  }) async {
    return const [];
  }

  @override
  Future<List<BibleVerse>> getRange({
    required String translationId,
    required ScriptureReference reference,
  }) async {
    return const [];
  }
}
