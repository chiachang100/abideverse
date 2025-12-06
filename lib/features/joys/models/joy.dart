import 'package:equatable/equatable.dart';

class Joy extends Equatable {
  final int id;
  final int articleId;
  final String title;

  final String scriptureName;
  final String scriptureChapter;
  final String scriptureVerse;

  final String prelude;
  final String laugh;
  final String talk;

  final String photoUrl;
  final String videoId;
  final String videoName;

  //final int likes;
  int likes;
  final int type;
  final bool isNew;
  final String category;

  Joy({
    required this.id,
    required this.articleId,
    required this.title,
    required this.scriptureName,
    required this.scriptureChapter,
    required this.scriptureVerse,
    required this.prelude,
    required this.laugh,
    required this.talk,
    required this.photoUrl,
    required this.videoId,
    required this.videoName,
    required this.likes,
    required this.type,
    required this.isNew,
    required this.category,
  });

  factory Joy.fromJson(Map<String, dynamic> json) {
    return Joy(
      id: json['id'] as int,
      articleId: json['articleId'] as int,
      title: json['title'] as String,
      scriptureName: json['scriptureName'] as String,
      scriptureChapter: json['scriptureChapter'] as String,
      scriptureVerse: json['scriptureVerse'] as String,
      prelude: json['prelude'] as String,
      laugh: json['laugh'] as String,
      talk: json['talk'] as String,
      photoUrl: json['photoUrl'] as String,
      videoId: json['videoId'] as String,
      videoName: json['videoName'] as String,
      likes: json['likes'] as int,
      type: json['type'] as int,
      isNew: json['isNew'] as bool,
      category: json['category'] as String,
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
      'prelude': prelude,
      'laugh': laugh,
      'talk': talk,
      'photoUrl': photoUrl,
      'videoId': videoId,
      'videoName': videoName,
      'likes': likes,
      'type': type,
      'isNew': isNew,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
    id,
    articleId,
    title,
    scriptureName,
    scriptureChapter,
    scriptureVerse,
    prelude,
    laugh,
    talk,
    photoUrl,
    videoId,
    videoName,
    likes,
    type,
    isNew,
    category,
  ];
}
