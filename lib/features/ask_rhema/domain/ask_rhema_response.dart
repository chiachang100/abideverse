import '../../bible/domain/bible_verse.dart';

class AskRhemaResponse {
  const AskRhemaResponse({required this.answer, required this.sources});

  final String answer;
  final List<BibleVerse> sources;
}
