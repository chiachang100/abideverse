class AppVideo {
  final String id;
  final String title;
  final String author;
  final AppThumbnails thumbnails; // Nested for consistency
  final String? description;

  AppVideo({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnails,
    this.description,
  });
}

class AppThumbnails {
  final String lowResUrl;
  final String mediumResUrl;
  final String highResUrl;

  AppThumbnails({
    required this.lowResUrl,
    required this.mediumResUrl,
    required this.highResUrl,
  });
}
