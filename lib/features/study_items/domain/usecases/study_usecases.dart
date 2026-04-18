import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/core/utils/use_case.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/revision_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/domain/repositories/revision_repository.dart';
import 'package:study_smart/features/study_items/domain/repositories/study_repository.dart';

// ── Decks ──────────────────────────────────────────────────────────────────

class GetDecksUseCase implements UseCase<List<DeckEntity>, NoParams> {
  final StudyRepository repository;
  GetDecksUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeckEntity>>> call(NoParams params) =>
      repository.getDecks();
}

class CreateDeckUseCase implements UseCase<DeckEntity, DeckEntity> {
  final StudyRepository repository;
  CreateDeckUseCase(this.repository);

  @override
  Future<Either<Failure, DeckEntity>> call(DeckEntity params) =>
      repository.createDeck(params);
}

class UpdateDeckUseCase implements UseCase<void, DeckEntity> {
  final StudyRepository repository;
  UpdateDeckUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeckEntity params) =>
      repository.updateDeck(params);
}

class DeleteDeckUseCase implements UseCase<void, String> {
  final StudyRepository repository;
  DeleteDeckUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deleteDeck(params);
}

// ── Study Items ────────────────────────────────────────────────────────────

class GetItemsByDeckUseCase implements UseCase<List<StudyItemEntity>, String> {
  final StudyRepository repository;
  GetItemsByDeckUseCase(this.repository);

  @override
  Future<Either<Failure, List<StudyItemEntity>>> call(String params) =>
      repository.getItemsByDeck(params);
}

class AddItemUseCase implements UseCase<StudyItemEntity, StudyItemEntity> {
  final StudyRepository repository;
  AddItemUseCase(this.repository);

  @override
  Future<Either<Failure, StudyItemEntity>> call(StudyItemEntity params) =>
      repository.addItem(params);
}

class UpdateItemUseCase implements UseCase<void, StudyItemEntity> {
  final StudyRepository repository;
  UpdateItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(StudyItemEntity params) =>
      repository.updateItem(params);
}

class DeleteItemUseCase implements UseCase<void, String> {
  final StudyRepository repository;
  DeleteItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deleteItem(params);
}

// ── Revisions ──────────────────────────────────────────────────────────────

class CompleteRevisionParams {
  const CompleteRevisionParams({
    required this.revision,
    required this.item,
    required this.quality,
  });
  final RevisionEntity revision;
  final StudyItemEntity item;
  final int quality;
}

class CompleteRevisionUseCase
    implements UseCase<StudyItemEntity, CompleteRevisionParams> {
  CompleteRevisionUseCase(this.repository);
  final RevisionRepository repository;

  @override
  Future<Either<Failure, StudyItemEntity>> call(
          CompleteRevisionParams params) =>
      repository.completeRevision(
        revision: params.revision,
        item: params.item,
        quality: params.quality,
      );
}

