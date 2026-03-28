// lib/features/treasures/models/treasure.dart

class Treasure {
  final int articleId;
  final String title;
  final String treasureImage;
  final String treasureMeaning;
  final String treasureStory;
  final String treasureRealLife;
  final int likes;
  final int type;
  final String category;

  Treasure({
    required this.articleId,
    required this.title,
    required this.treasureImage,
    required this.treasureMeaning,
    required this.treasureStory,
    required this.treasureRealLife,
    required this.likes,
    required this.type,
    required this.category,
  });

  factory Treasure.fromJson(Map<String, dynamic> json) {
    return Treasure(
      articleId: json['articleId'] ?? 0,
      title: json['title'] ?? '',
      treasureImage: json['treasureImage'] ?? '',
      treasureMeaning: json['treasureMeaning'] ?? '',
      treasureStory: json['treasureStory'] ?? '',
      treasureRealLife: json['treasureRealLife'] ?? '',
      likes: json['likes'] ?? 0,
      type: json['type'] ?? 0,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'title': title,
      'treasureImage': treasureImage,
      'treasureMeaning': treasureMeaning,
      'treasureStory': treasureStory,
      'treasureRealLife': treasureRealLife,
      'likes': likes,
      'type': type,
      'category': category,
    };
  }
}
