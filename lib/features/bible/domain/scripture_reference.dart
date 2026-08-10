class ScriptureReference {
  final String bookId;
  final int chapter;
  final int? startVerse;
  final int? endVerse;

  const ScriptureReference({
    required this.bookId,
    required this.chapter,
    this.startVerse,
    this.endVerse,
  });
}
