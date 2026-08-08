import 'ask_rhema_message.dart';

class AskRhemaRequest {
  const AskRhemaRequest({
    required this.question,
    required this.translationId,
    this.history = const [],
  });

  final String question;
  final String translationId;
  final List<AskRhemaMessage> history;
}
