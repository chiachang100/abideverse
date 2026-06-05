class WPPost {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String date;
  final String link;

  WPPost({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    required this.link,
  });

  factory WPPost.fromJson(Map<String, dynamic> json) {
    return WPPost(
      id: json['id'],
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      excerpt: json['excerpt']['rendered'],
      date: json['date'],
      link: json['link'],
    );
  }
}
