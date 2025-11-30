import 'joy.dart';

class Scripture {
  final int id;
  final int articleId;
  final String title;
  final String name;
  final String verse;
  final joys = <Joy>[];

  Scripture(
    this.id,
    this.articleId,
    this.title,
    this.name,
    this.verse,
  );
}
