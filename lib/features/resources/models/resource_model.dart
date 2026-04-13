import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ResourceModel extends Equatable {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String markdownContent;
  final String iconName;
  final int colorValue;
  final int displayOrder;
  final bool isActive;
  final DateTime updatedAt;

  const ResourceModel({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.markdownContent,
    required this.iconName,
    required this.colorValue,
    required this.displayOrder,
    required this.isActive,
    required this.updatedAt,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      id: doc.id,
      titleKey: data['titleKey'] as String? ?? '',
      descriptionKey: data['descriptionKey'] as String? ?? '',
      markdownContent: data['markdownContent'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'library_books',
      colorValue: data['colorValue'] as int? ?? 0xFF4285F4,
      displayOrder: data['displayOrder'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'markdownContent': markdownContent,
      'iconName': iconName,
      'colorValue': colorValue,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  List<Object?> get props => [
    id,
    titleKey,
    descriptionKey,
    markdownContent,
    iconName,
    colorValue,
    displayOrder,
    isActive,
    updatedAt,
  ];
}
