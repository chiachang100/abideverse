enum GalleryItemType { playlist, externalLink }

class GalleryItem {
  final String title;
  final String subtitle;
  final String target;
  final GalleryItemType type;

  const GalleryItem({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.type,
  });

  bool get isPlaylist => type == GalleryItemType.playlist;
}
