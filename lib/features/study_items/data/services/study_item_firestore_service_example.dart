// ────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE — Study Item Firestore CRUD
//
// This file is for reference only.  Do NOT include it in production builds.
// It shows how to wire up and use StudyItemFirestoreService directly.
// ────────────────────────────────────────────────────────────────────────────

// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:study_smart/core/services/firebase_service.dart';
import 'package:study_smart/core/services/firestore_service.dart';
import 'package:study_smart/features/study_items/data/models/study_item_model.dart';
import 'package:study_smart/features/study_items/data/services/study_item_firestore_service.dart';

/// Demonstrates the four CRUD methods exposed by [StudyItemFirestoreService].
Future<void> runStudyItemCrudExample() async {
  // ── 1. Bootstrap Firebase (already done in main.dart) ─────────────────────
  await Firebase.initializeApp();

  // ── 2. Build the service graph ─────────────────────────────────────────────
  final firebaseService = FirebaseService.instance();

  final firestoreService = FirestoreService(
    firebaseService: firebaseService,
  );

  final studyItemService = StudyItemFirestoreService(
    firestoreService: firestoreService,
  );

  // ── Sample identifiers ─────────────────────────────────────────────────────
  const userId = 'user_abc123';
  const deckId = 'deck_xyz456';
  const itemId = 'item_001';

  // ── CREATE ─────────────────────────────────────────────────────────────────
  // addStudyItem() writes a new flashcard document to:
  //   users/{userId}/decks/{deckId}/items/{itemId}

  final newItem = StudyItemModel(
    id: itemId,
    deckId: deckId,
    userId: userId,
    front: 'What is the powerhouse of the cell?',
    back: 'The mitochondria.',
    tags: ['biology', 'cell'],
    createdAt: DateTime.now(),
    nextReviewDate: DateTime.now(),
    easeFactor: 250,
    interval: 0,
    repetitions: 0,
  );

  final created = await studyItemService.addStudyItem(newItem);
  print('✅ Created: ${created.front}');

  // ── READ ───────────────────────────────────────────────────────────────────
  // getStudyItems() returns all items in the deck, ordered by createdAt.

  final items = await studyItemService.getStudyItems(
    userId: userId,
    deckId: deckId,
  );
  print('📚 Fetched ${items.length} item(s)');
  for (final item in items) {
    print('   • [${item.id}] ${item.front}');
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  // updateStudyItem() merges changed fields into the existing Firestore doc.

  final updated = StudyItemModel(
    id: itemId,
    deckId: deckId,
    userId: userId,
    front: 'What is the powerhouse of the cell?',
    back: 'The mitochondria — it produces ATP via cellular respiration.',
    tags: ['biology', 'cell', 'energy'],
    createdAt: newItem.createdAt,
    nextReviewDate: DateTime.now().add(const Duration(days: 1)),
    easeFactor: 260,
    interval: 1,
    repetitions: 1,
  );

  await studyItemService.updateStudyItem(updated);
  print('✏️  Updated item back to: "${updated.back}"');

  // ── REAL-TIME STREAM ───────────────────────────────────────────────────────
  // watchStudyItems() gives you a live snapshot stream — great for Providers.
  //
  // final stream = studyItemService.watchStudyItems(userId: userId, deckId: deckId);
  // stream.listen((items) => print('Live update: ${items.length} items'));

  // ── DELETE ─────────────────────────────────────────────────────────────────
  // deleteStudyItem() permanently removes the Firestore document.

  await studyItemService.deleteStudyItem(
    userId: userId,
    deckId: deckId,
    itemId: itemId,
  );
  print('🗑️  Deleted item $itemId');
}

// ── How to use inside a Provider / ViewModel ──────────────────────────────────
//
// @override
// Future<void> loadItems() async {
//   state = StudyItemsLoading();
//   try {
//     final items = await _studyItemService.getStudyItems(
//       userId: _userId,
//       deckId: _deckId,
//     );
//     state = StudyItemsLoaded(items);
//   } on ServerException catch (e) {
//     state = StudyItemsError(e.message);
//   }
// }
