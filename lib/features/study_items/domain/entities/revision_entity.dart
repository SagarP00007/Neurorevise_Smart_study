import 'package:equatable/equatable.dart';

/// Represents a single scheduled revision for a study item.
///
/// Firestore path: `users/{uid}/revisions/{revisionId}`
class RevisionEntity extends Equatable {
  const RevisionEntity({
    required this.id,
    required this.itemId,
    required this.deckId,
    required this.userId,
    required this.scheduledDate,
    required this.intervalDay,
    required this.isCompleted,
    this.completedAt,
    this.qualityRating,
  });

  final String id;
  final String itemId;
  final String deckId;
  final String userId;

  /// Which step in the schedule this is (1, 3, 7, 15, or 30 days).
  final int intervalDay;

  final DateTime scheduledDate;
  final bool isCompleted;
  final DateTime? completedAt;

  /// SM-2 quality rating (0–5) given when the revision was completed.
  final int? qualityRating;

  bool get isDue => !scheduledDate.isAfter(DateTime.now());

  RevisionEntity copyWith({
    String? id,
    String? itemId,
    String? deckId,
    String? userId,
    int? intervalDay,
    DateTime? scheduledDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? qualityRating,
  }) {
    return RevisionEntity(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      intervalDay: intervalDay ?? this.intervalDay,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      qualityRating: qualityRating ?? this.qualityRating,
    );
  }

  @override
  List<Object?> get props => [
        id, itemId, deckId, userId,
        intervalDay, scheduledDate,
        isCompleted, completedAt, qualityRating,
      ];
}
