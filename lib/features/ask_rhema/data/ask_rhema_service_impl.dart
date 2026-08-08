import '../../bible/domain/bible_repository.dart';
import '../domain/ask_rhema_request.dart';
import '../domain/ask_rhema_response.dart';
import '../domain/ask_rhema_service.dart';
import '../../../shared/services/ai/ai_service.dart';

class AskRhemaServiceImpl implements AskRhemaService {
  AskRhemaServiceImpl({
    required BibleRepository bibleRepository,
    required AIService aiService,
  }) : _bibleRepository = bibleRepository,
       _aiService = aiService;

  final BibleRepository _bibleRepository;
  final AIService _aiService;

  @override
  Future<AskRhemaResponse> ask(AskRhemaRequest request) async {
    final sources = await _bibleRepository.search(
      translationId: request.translationId,
      query: request.question,
      limit: 8,
    );

    final prompt = _buildPrompt(request: request, sources: sources);

    final answer = await _aiService.generateText(prompt);

    return AskRhemaResponse(answer: answer ?? '', sources: sources);
  }

  String _buildPrompt({
    required AskRhemaRequest request,
    required List sources,
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
You are AskRhema, a Bible study companion.

Answer the user's question using the supplied Scripture passages.

Rules:
1. Do not invent Scripture references.
2. Clearly distinguish Scripture from interpretation.
3. If the supplied passages are insufficient, say so.
4. Respect the selected Bible translation.
5. Answer in the user's language.
6. Do not claim divine revelation or speak as though you are God.
7. Encourage the user toward Scripture and thoughtful reflection.

SCRIPTURE SOURCES:

$scriptureContext

CONVERSATION:

$history

USER QUESTION:

${request.question}
''';
  }
}
