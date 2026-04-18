import 'package:equatable/equatable.dart';

class DeckEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String subject;
  final int colorValue; // Store color as int for persistence
  final int itemCount;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;

  const DeckEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.colorValue,
    required this.itemCount,
    required this.createdAt,
    this.lastReviewedAt,
  });

  DeckEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? subject,
    int? colorValue,
    int? itemCount,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
  }) {
    return DeckEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      colorValue: colorValue ?? this.colorValue,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        subject,
        colorValue,
        itemCount,
        createdAt,
        lastReviewedAt,
      ];
}
