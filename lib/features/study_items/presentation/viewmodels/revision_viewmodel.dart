import 'package:flutter/foundation.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/features/study_items/domain/entities/revision_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/domain/logic/sm2_algorithm.dart';
import 'package:study_smart/features/study_items/domain/repositories/revision_repository.dart';
import 'package:study_smart/features/study_items/domain/usecases/study_usecases.dart';

// ── Result type for completeRevision ─────────────────────────────────────────

class CompleteRevisionResult {
  const CompleteRevisionResult({this.updatedItem, this.error});
  final StudyItemEntity? updatedItem;
  final String? error;
  bool get isSuccess => error == null;
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class RevisionViewModel extends ChangeNotifier {
  RevisionViewModel({
    required this.repository,
    required this.completeRevisionUseCase,
  });

  final RevisionRepository repository;
  final CompleteRevisionUseCase completeRevisionUseCase;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isCompleting = false;
  String? _error;

  bool get isCompleting => _isCompleting;
  String? get error => _error;

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Live stream of revisions due today across all decks.
  Stream<List<RevisionEntity>> watchDueRevisions() =>
      repository.watchDueRevisions();

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Rates a revision using [PerformanceRating] — the recommended API.
  ///
  /// Maps hard/medium/easy → SM-2 quality (1/3/5), then calls [completeRevision].
  ///
  /// Example:
  /// ```dart
  /// final result = await revVm.rateRevision(
  ///   revision: revision,
  ///   item: item,
  ///   rating: PerformanceRating.easy,
  /// );
  /// if (result.isSuccess) {
  ///   print('Next review: ${result.updatedItem!.nextReviewDate}');
  /// }
  /// ```
  Future<CompleteRevisionResult> rateRevision({
    required RevisionEntity revision,
    required StudyItemEntity item,
    required PerformanceRating rating,
  }) =>
      completeRevision(
        revision: revision,
        item: item,
        quality: rating.quality,
      );

  /// Completes a revision with a raw SM-2 quality value (0–5).
  ///
  /// Prefer [rateRevision] unless you need fine-grained control.
  Future<CompleteRevisionResult> completeRevision({
    required RevisionEntity revision,
    required StudyItemEntity item,
    required int quality,
  }) async {
    _isCompleting = true;
    _error = null;
    notifyListeners();

    final result = await completeRevisionUseCase(
      CompleteRevisionParams(
        revision: revision,
        item: item,
        quality: quality,
      ),
    );

    return result.fold(
      (failure) {
        _isCompleting = false;
        _error = failure.message;
        notifyListeners();
        return CompleteRevisionResult(error: failure.message);
      },
      (updatedItem) {
        _isCompleting = false;
        _error = null;
        notifyListeners();
        return CompleteRevisionResult(updatedItem: updatedItem);
      },
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
