// lib/features/scriptures/models/scripture.dart

class Scripture {
  final int id;
  final int articleId;
  final String title;
  final String scriptureName;
  final String scriptureChapter;
  final String scriptureVerse;
  final String zhCNScriptureVerse;
  final int likes;
  final int type;
  final String scriptureReader;
  final String category;
  final String videoId;
  final String videoName;
  final bool isRicherDaily;

  Scripture({
    required this.id,
    required this.articleId,
    required this.title,
    required this.scriptureName,
    required this.scriptureChapter,
    required this.scriptureVerse,
    required this.zhCNScriptureVerse,
    required this.likes,
    required this.type,
    required this.scriptureReader,
    required this.category,
    required this.videoId,
    required this.videoName,
    required this.isRicherDaily,
  });

  factory Scripture.fromJson(Map<String, dynamic> json) {
    return Scripture(
      id: json['id'] ?? 0,
      articleId: json['articleId'] ?? 0,
      title: json['title'] ?? '',
      scriptureName: json['scriptureName'] ?? '',
      scriptureChapter: json['scriptureChapter'] ?? '',
      scriptureVerse: json['scriptureVerse'] ?? '',
      zhCNScriptureVerse: json['zhCNScriptureVerse'] ?? '',
      likes: json['likes'] ?? 0,
      type: json['type'] ?? 0,
      scriptureReader: json['scriptureReader'] ?? '',
      category: json['category'] ?? '',
      videoId: json['videoId'] ?? '',
      videoName: json['videoName'] ?? '',
      isRicherDaily: json['isRicherDaily'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'title': title,
      'scriptureName': scriptureName,
      'scriptureChapter': scriptureChapter,
      'scriptureVerse': scriptureVerse,
      'zhCNScriptureVerse': zhCNScriptureVerse,
      'likes': likes,
      'type': type,
      'scriptureReader': scriptureReader,
      'category': category,
      'videoId': videoId,
      'videoName': videoName,
      'isRicherDaily': isRicherDaily,
    };
  }
}
