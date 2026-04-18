import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';

class StudyItemModel extends StudyItemEntity {
  const StudyItemModel({
    required super.id,
    required super.deckId,
    required super.userId,
    required super.front,
    required super.back,
    required super.tags,
    required super.createdAt,
    super.lastReviewedAt,
    required super.nextReviewDate,
    super.easeFactor,
    super.interval,
    super.repetitions,
  });

  factory StudyItemModel.fromEntity(StudyItemEntity entity) {
    return StudyItemModel(
      id: entity.id,
      deckId: entity.deckId,
      userId: entity.userId,
      front: entity.front,
      back: entity.back,
      tags: entity.tags,
      createdAt: entity.createdAt,
      lastReviewedAt: entity.lastReviewedAt,
      nextReviewDate: entity.nextReviewDate,
      easeFactor: entity.easeFactor,
      interval: entity.interval,
      repetitions: entity.repetitions,
    );
  }

  factory StudyItemModel.fromMap(Map<String, dynamic> map, String id) {
    return StudyItemModel(
      id: id,
      deckId: map['deckId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      front: map['front'] as String? ?? '',
      back: map['back'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? []),
      createdAt: DateTime.parse(
          map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.parse(map['lastReviewedAt'] as String)
          : null,
      nextReviewDate: DateTime.parse(
          map['nextReviewDate'] as String? ?? DateTime.now().toIso8601String()),
      easeFactor: map['easeFactor'] as int? ?? 250,
      interval: map['interval'] as int? ?? 0,
      repetitions: map['repetitions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId,
      'userId': userId,
      'front': front,
      'back': back,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
    };
  }
}
