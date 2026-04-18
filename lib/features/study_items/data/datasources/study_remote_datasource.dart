import 'package:study_smart/core/services/firestore_service.dart';
import 'package:study_smart/features/study_items/data/models/deck_model.dart';
import 'package:study_smart/features/study_items/data/models/study_item_model.dart';

abstract class StudyRemoteDataSource {
  Future<List<DeckModel>> getDecks(String userId);
  Future<DeckModel> createDeck(DeckModel deck);
  Future<void> updateDeck(DeckModel deck);
  Future<void> deleteDeck(String userId, String deckId);
  Stream<List<DeckModel>> watchDecks(String userId);

  Future<List<StudyItemModel>> getItems(String userId, String deckId);
  Future<StudyItemModel> addItem(StudyItemModel item);
  Future<void> updateItem(StudyItemModel item);
  Future<void> deleteItem(String userId, String deckId, String itemId);
  Stream<List<StudyItemModel>> watchItems(String userId, String deckId);
  Stream<List<StudyItemModel>> watchDueItemsAcrossDecks(String userId);

  Future<void> createRevisionSchedule(String userId, String deckId, String itemId);
  Future<void> markRevisionComplete(String userId, String revisionId);
}

class FirestoreStudyRemoteDataSource implements StudyRemoteDataSource {
  final FirestoreService firestoreService;

  FirestoreStudyRemoteDataSource({required this.firestoreService});

  // ── Decks ──────────────────────────────────────────────────────────────────

  @override
  Future<List<DeckModel>> getDecks(String userId) async {
    final docs = await firestoreService.getCollection(
      collectionPath: 'users/$userId/decks',
      orderByField: 'createdAt',
      descending: true,
    );
    return docs.map((d) => DeckModel.fromMap(d, d['id'])).toList();
  }

  @override
  Future<DeckModel> createDeck(DeckModel deck) async {
    final path = 'users/${deck.userId}/decks/${deck.id}';
    await firestoreService.setDocument(path: path, data: deck.toMap());
    return deck;
  }

  @override
  Future<void> updateDeck(DeckModel deck) async {
    final path = 'users/${deck.userId}/decks/${deck.id}';
    await firestoreService.updateDocument(path: path, data: deck.toMap());
  }

  @override
  Future<void> deleteDeck(String userId, String deckId) async {
    final path = 'users/$userId/decks/$deckId';
    await firestoreService.deleteDocument(path);
  }

  @override
  Stream<List<DeckModel>> watchDecks(String userId) {
    return firestoreService
        .watchCollection(
          collectionPath: 'users/$userId/decks',
          orderByField: 'createdAt',
          descending: true,
        )
        .map((docs) =>
            docs.map((d) => DeckModel.fromMap(d, d['id'])).toList());
  }

  // ── Study Items ────────────────────────────────────────────────────────────

  @override
  Future<List<StudyItemModel>> getItems(String userId, String deckId) async {
    final docs = await firestoreService.getCollection(
      collectionPath: 'users/$userId/decks/$deckId/items',
      orderByField: 'createdAt',
    );
    return docs.map((d) => StudyItemModel.fromMap(d, d['id'])).toList();
  }

  @override
  Future<StudyItemModel> addItem(StudyItemModel item) async {
    final path = 'users/${item.userId}/decks/${item.deckId}/items/${item.id}';
    await firestoreService.setDocument(path: path, data: item.toMap());
    return item;
  }

  @override
  Future<void> updateItem(StudyItemModel item) async {
    final path = 'users/${item.userId}/decks/${item.deckId}/items/${item.id}';
    await firestoreService.updateDocument(path: path, data: item.toMap());
  }

  @override
  Future<void> deleteItem(String userId, String deckId, String itemId) async {
    final path = 'users/$userId/decks/$deckId/items/$itemId';
    await firestoreService.deleteDocument(path);
  }

  @override
  Stream<List<StudyItemModel>> watchItems(String userId, String deckId) {
    return firestoreService
        .watchCollection(
          collectionPath: 'users/$userId/decks/$deckId/items',
          orderByField: 'createdAt',
        )
        .map((docs) =>
            docs.map((d) => StudyItemModel.fromMap(d, d['id'])).toList());
  }

  @override
  Stream<List<StudyItemModel>> watchDueItemsAcrossDecks(String userId) {
    final now = DateTime.now().toIso8601String();
    
    // Server-side filtering forces the database engine to only return items 
    // owned by the user, providing an additional layer of security and 
    // significant bandwidth savings vs downloading the global collection and
    // filtering client-side.
    return firestoreService
        .watchCollectionGroupWhere(
          collectionId: 'items',
          whereField: 'userId',
          isEqualTo: userId,
          whereLtEqField: 'nextReviewDate',
          lessThanOrEqualTo: now,
          orderByField: 'nextReviewDate',
        )
        .map((docs) => docs.map((d) => StudyItemModel.fromMap(d, d['id'])).toList());
  }

  // ── Revisions ──────────────────────────────────────────────────────────────
  
  @override
  Future<void> createRevisionSchedule(String userId, String deckId, String itemId) async {
    const defaultIntervals = [1, 3, 7, 15, 30];
    final now = DateTime.now();

    final entries = defaultIntervals.map((days) {
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString() + days.toString(),
        'itemId': itemId,
        'deckId': deckId,
        'userId': userId,
        'scheduledDate': now.add(Duration(days: days)).toIso8601String(),
        'isCompleted': false,
        'completedAt': null,
      };
    }).toList();

    await firestoreService.runBatch((batch) async {
      final db = firestoreService.firebaseService.firestore;
      for (final entry in entries) {
        final docRef = db.doc('users/$userId/revisions/${entry['id']}');
        batch.set(docRef, entry);
      }
    });
  }

  @override
  Future<void> markRevisionComplete(String userId, String revisionId) async {
    final path = 'users/$userId/revisions/$revisionId';
    await firestoreService.updateDocument(
      path: path,
      data: {
        'isCompleted': true,
        'completedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
