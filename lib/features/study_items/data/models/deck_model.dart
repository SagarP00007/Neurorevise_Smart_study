import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';

class DeckModel extends DeckEntity {
  const DeckModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.subject,
    required super.colorValue,
    required super.itemCount,
    required super.createdAt,
    super.lastReviewedAt,
  });

  factory DeckModel.fromEntity(DeckEntity entity) {
    return DeckModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      subject: entity.subject,
      colorValue: entity.colorValue,
      itemCount: entity.itemCount,
      createdAt: entity.createdAt,
      lastReviewedAt: entity.lastReviewedAt,
    );
  }

  factory DeckModel.fromMap(Map<String, dynamic> map, String id) {
    return DeckModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0,
      itemCount: map['itemCount'] as int? ?? 0,
      createdAt: DateTime.parse(
          map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.parse(map['lastReviewedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subject': subject,
      'colorValue': colorValue,
      'itemCount': itemCount,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    };
  }
}
