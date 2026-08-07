class ScriptureReference {
  final String bookId;
  final int chapter;
  final int startVerse;
  final int? endVerse;

  const ScriptureReference({
    required this.bookId,
    required this.chapter,
    required this.startVerse,
    this.endVerse,
  });
}
