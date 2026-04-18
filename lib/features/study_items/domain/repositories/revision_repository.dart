import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/features/study_items/domain/entities/revision_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';

abstract class RevisionRepository {
  /// Live stream of pending revisions due on or before today.
  Stream<List<RevisionEntity>> watchDueRevisions();

  /// Live stream of ALL revisions for [itemId].
  Stream<List<RevisionEntity>> watchRevisionsForItem(String itemId);

  /// Complete a revision: marks it done and updates SM-2 params on the item.
  ///
  /// [quality]: SM-2 rating 0–5.
  Future<Either<Failure, StudyItemEntity>> completeRevision({
    required RevisionEntity revision,
    required StudyItemEntity item,
    required int quality,
  });

  /// Fetch all pending (not completed) revisions for [itemId].
  Future<Either<Failure, List<RevisionEntity>>> getPendingRevisionsForItem(
      String itemId);
}
