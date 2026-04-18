import 'package:equatable/equatable.dart';

class RevisionEntryModel extends Equatable {
  final String id;
  final String itemId;
  final String deckId;
  final String userId;
  final int intervalDay;
  final DateTime scheduledDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? qualityRating;

  const RevisionEntryModel({
    required this.id,
    required this.itemId,
    required this.deckId,
    required this.userId,
    required this.intervalDay,
    required this.scheduledDate,
    required this.isCompleted,
    this.completedAt,
    this.qualityRating,
  });

  RevisionEntryModel copyWith({
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
    return RevisionEntryModel(
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

  factory RevisionEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return RevisionEntryModel(
      id: id,
      itemId: map['itemId'] as String? ?? '',
      deckId: map['deckId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      intervalDay: map['intervalDay'] as int? ?? 1,
      scheduledDate: DateTime.parse(
          map['scheduledDate'] as String? ?? DateTime.now().toIso8601String()),
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      qualityRating: map['qualityRating'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'deckId': deckId,
      'userId': userId,
      'intervalDay': intervalDay,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'qualityRating': qualityRating,
    };
  }

  @override
  List<Object?> get props => [
        id, itemId, deckId, userId,
        intervalDay, scheduledDate,
        isCompleted, completedAt, qualityRating,
      ];
}
