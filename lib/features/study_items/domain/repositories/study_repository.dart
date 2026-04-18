import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';

abstract class StudyRepository {
  // ── Decks ──────────────────────────────────────────────────────────────────
  Future<Either<Failure, List<DeckEntity>>> getDecks();
  Future<Either<Failure, DeckEntity>> createDeck(DeckEntity deck);
  Future<Either<Failure, void>> updateDeck(DeckEntity deck);
  Future<Either<Failure, void>> deleteDeck(String deckId);
  Stream<List<DeckEntity>> watchDecks();

  // ── Study Items ────────────────────────────────────────────────────────────
  Future<Either<Failure, List<StudyItemEntity>>> getItemsByDeck(String deckId);
  Future<Either<Failure, StudyItemEntity>> addItem(StudyItemEntity item);
  Future<Either<Failure, void>> updateItem(StudyItemEntity item);
  Future<Either<Failure, void>> deleteItem(String itemId);
  Stream<List<StudyItemEntity>> watchItems(String deckId);
  Stream<List<StudyItemEntity>> watchDueItemsAcrossDecks();
  
  // ── Sync ───────────────────────────────────────────────────────────────────
  Future<void> syncRemote();
}
