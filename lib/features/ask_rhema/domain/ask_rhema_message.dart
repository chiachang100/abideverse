enum AskRhemaRole { user, assistant }

class AskRhemaMessage {
  const AskRhemaMessage({required this.role, required this.text});

  final AskRhemaRole role;
  final String text;
}
