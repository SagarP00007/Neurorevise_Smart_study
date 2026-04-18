import 'package:equatable/equatable.dart';

class StudyItemEntity extends Equatable {
  final String id;
  final String deckId;
  final String userId;
  final String front;
  final String back;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewDate;
  final int easeFactor; // SM-2 parameter (in percentage, e.g. 250)
  final int interval; // SM-2 parameter (in days)
  final int repetitions; // SM-2 parameter (count)

  const StudyItemEntity({
    required this.id,
    required this.deckId,
    required this.userId,
    required this.front,
    required this.back,
    required this.tags,
    required this.createdAt,
    this.lastReviewedAt,
    required this.nextReviewDate,
    this.easeFactor = 250,
    this.interval = 0,
    this.repetitions = 0,
  });

  StudyItemEntity copyWith({
    String? id,
    String? deckId,
    String? userId,
    String? front,
    String? back,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewDate,
    int? easeFactor,
    int? interval,
    int? repetitions,
  }) {
    return StudyItemEntity(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      front: front ?? this.front,
      back: back ?? this.back,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        userId,
        front,
        back,
        tags,
        createdAt,
        lastReviewedAt,
        nextReviewDate,
        easeFactor,
        interval,
        repetitions,
      ];
}
