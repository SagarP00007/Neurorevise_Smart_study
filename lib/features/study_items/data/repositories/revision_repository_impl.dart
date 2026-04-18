import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/exceptions.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/features/study_items/data/models/revision_entry_model.dart';
import 'package:study_smart/features/study_items/data/models/study_item_model.dart';
import 'package:study_smart/features/study_items/data/services/revision_firestore_service.dart';
import 'package:study_smart/features/study_items/domain/entities/revision_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/domain/logic/sm2_algorithm.dart';
import 'package:study_smart/features/study_items/domain/repositories/revision_repository.dart';
import 'package:study_smart/features/auth/domain/repositories/auth_repository.dart';

class RevisionRepositoryImpl implements RevisionRepository {
  RevisionRepositoryImpl({
    required this.revisionService,
    required this.authRepository,
  });

  final RevisionFirestoreService revisionService;
  final AuthRepository authRepository;

  // ── Auth helper ──────────────────────────────────────────────────────────

  Future<String> _getUserId() async {
    final result = await authRepository.getCurrentUser();
    return result.fold(
      (f) => throw AuthException(message: f.message),
      (user) => user?.uid ?? (throw const AuthException(message: 'Not logged in')),
    );
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  static RevisionEntity _toEntity(RevisionEntryModel m) => RevisionEntity(
        id: m.id,
        itemId: m.itemId,
        deckId: m.deckId,
        userId: m.userId,
        intervalDay: m.intervalDay,
        scheduledDate: m.scheduledDate,
        isCompleted: m.isCompleted,
        completedAt: m.completedAt,
        qualityRating: m.qualityRating,
      );

  // ── Streams ───────────────────────────────────────────────────────────────

  @override
  Stream<List<RevisionEntity>> watchDueRevisions() async* {
    try {
      final userId = await _getUserId();
      yield* revisionService
          .watchDueRevisions(userId)
          .map((list) => list.map(_toEntity).toList());
    } on AuthException catch (e) {
      throw e;
    } catch (_) {
      yield [];
    }
  }

  @override
  Stream<List<RevisionEntity>> watchRevisionsForItem(String itemId) async* {
    try {
      final userId = await _getUserId();
      yield* revisionService
          .watchDueRevisions(userId) // already ordered by scheduledDate
          .map((list) => list
              .where((r) => r.itemId == itemId)
              .map(_toEntity)
              .toList());
    } catch (_) {
      yield [];
    }
  }

  // ── Complete revision ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, StudyItemEntity>> completeRevision({
    required RevisionEntity revision,
    required StudyItemEntity item,
    required int quality,
  }) async {
    try {
      final userId = await _getUserId();

      // 1. Run SM-2 algorithm
      final sm2 = SM2Algorithm.calculate(
        quality: quality,
        previousEaseFactor: item.easeFactor,
        previousInterval: item.interval,
        previousRepetitions: item.repetitions,
      );

      // 2. Build updated item
      final updatedItem = item.copyWith(
        easeFactor: sm2.easeFactor,
        interval: sm2.interval,
        repetitions: sm2.repetitions,
        nextReviewDate: sm2.nextReviewDate,
        lastReviewedAt: DateTime.now(),
      );

      // 3. Build the Firestore fields map for the item update
      final itemFields = StudyItemModel.fromEntity(updatedItem).toMap()
        ..['lastReviewedAt'] = DateTime.now().toIso8601String()
        ..['nextReviewDate'] = sm2.nextReviewDate.toIso8601String()
        ..['easeFactor'] = sm2.easeFactor
        ..['interval'] = sm2.interval
        ..['repetitions'] = sm2.repetitions;

      // 4. Atomic batch: mark revision done + update item SM-2 fields
      await revisionService.completeRevisionAndUpdateItem(
        userId: userId,
        deckId: revision.deckId,
        itemId: revision.itemId,
        revisionId: revision.id,
        qualityRating: quality,
        updatedItemFields: itemFields,
      );

      return Right(updatedItem);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<RevisionEntity>>> getPendingRevisionsForItem(
      String itemId) async {
    try {
      final userId = await _getUserId();
      final models = await revisionService.getPendingRevisionsForItem(
        userId: userId,
        itemId: itemId,
      );
      return Right(models.map(_toEntity).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
