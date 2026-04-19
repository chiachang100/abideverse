import 'package:equatable/equatable.dart';

class Treasure extends Equatable {
  final int articleId;
  final String title;
  final String treasureImage;
  final String treasureMeaning;
  final String treasureStory;
  final String treasureRealLife;
  final int likes;
  final int type;
  final bool isNew;
  final String category;

  const Treasure({
    required this.articleId,
    required this.title,
    required this.treasureImage,
    required this.treasureMeaning,
    required this.treasureStory,
    required this.treasureRealLife,
    required this.likes,
    required this.type,
    required this.isNew,
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
      isNew: json['isNew'] as bool,
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
      'isNew': isNew,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
    articleId,
    title,
    treasureImage,
    treasureMeaning,
    treasureStory,
    treasureRealLife,
    likes,
    type,
    isNew,
    category,
  ];
}
