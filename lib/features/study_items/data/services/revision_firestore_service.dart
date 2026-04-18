import 'package:study_smart/core/services/firestore_service.dart';
import 'package:study_smart/features/study_items/data/models/revision_entry_model.dart';
import 'package:uuid/uuid.dart';

/// Firestore service for managing spaced repetition schedules.
///
/// Stores revision entries under `users/{userId}/revisions/{revisionId}`.
class RevisionFirestoreService {
  RevisionFirestoreService({required this.firestoreService});

  final FirestoreService firestoreService;

  // ── Path helpers ──────────────────────────────────────────────────────────

  static String _collectionPath(String userId) => 'users/$userId/revisions';

  static String _documentPath(String userId, String revisionId) =>
      'users/$userId/revisions/$revisionId';

  // ── Schedule Creation ─────────────────────────────────────────────────────

  /// Creates a static revision schedule (1, 3, 7, 15, 30 days) for a newly
  /// added study item. Written atomically as a Firestore batch.
  Future<void> createScheduleForItem({
    required String userId,
    required String deckId,
    required String itemId,
  }) async {
    const defaultIntervals = [1, 3, 7, 15, 30];
    final now = DateTime.now();

    final entries = defaultIntervals.map((days) {
      return RevisionEntryModel(
        id: const Uuid().v4(),
        itemId: itemId,
        deckId: deckId,
        userId: userId,
        intervalDay: days,
        scheduledDate: now.add(Duration(days: days)),
        isCompleted: false,
      );
    }).toList();

    await firestoreService.runBatch((batch) async {
      final db = firestoreService.firebaseService.firestore;
      for (final entry in entries) {
        final docRef = db.doc(_documentPath(userId, entry.id));
        batch.set(docRef, entry.toMap());
      }
    });
  }

  // ── Updates ───────────────────────────────────────────────────────────────

  /// Marks a revision as completed with a quality rating.
  Future<void> markRevisionComplete({
    required String userId,
    required String revisionId,
    required int qualityRating,
  }) async {
    final path = _documentPath(userId, revisionId);
    await firestoreService.updateDocument(
      path: path,
      data: {
        'isCompleted': true,
        'completedAt': DateTime.now().toIso8601String(),
        'qualityRating': qualityRating,
      },
    );
  }

  /// Atomically marks the revision complete AND updates SM-2 fields on
  /// the parent study item in a single Firestore transaction.
  Future<void> completeRevisionAndUpdateItem({
    required String userId,
    required String deckId,
    required String itemId,
    required String revisionId,
    required int qualityRating,
    required Map<String, dynamic> updatedItemFields,
  }) async {
    await firestoreService.runBatch((batch) async {
      final db = firestoreService.firebaseService.firestore;

      // 1. Mark revision complete
      final revRef = db.doc(_documentPath(userId, revisionId));
      batch.update(revRef, {
        'isCompleted': true,
        'completedAt': DateTime.now().toIso8601String(),
        'qualityRating': qualityRating,
      });

      // 2. Write SM-2 fields back to the study item document
      final itemRef = db.doc(
          'users/$userId/decks/$deckId/items/$itemId');
      batch.update(itemRef, updatedItemFields);
    });
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Fetch all pending revisions for a specific item.
  Future<List<RevisionEntryModel>> getPendingRevisionsForItem({
    required String userId,
    required String itemId,
  }) async {
    // 🚀 OPTIMIZATION: Database engine queries bypass downloading full collections.
    final docs = await firestoreService.getCollectionWhere(
      collectionPath: _collectionPath(userId),
      whereField: 'itemId',
      isEqualTo: itemId,
      orderByField: 'scheduledDate',
    );
    return docs
        .where((d) => d['isCompleted'] == false)
        .map((d) => RevisionEntryModel.fromMap(d, d['id'] as String))
        .toList();
  }

  /// Real-time stream of revisions that are:
  ///   - owned by [userId]
  ///   - scheduled on or before the END of today
  ///
  /// Uses a native Firestore collectionGroup query so only matching documents
  /// are transferred (no full-collection scan).
  ///
  /// Required composite index (create once in Firebase console):
  ///   Collection group : revisions
  ///   Fields           : userId ASC, scheduledDate ASC
  Stream<List<RevisionEntryModel>> watchDueRevisions(String userId) {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .toIso8601String();

    return firestoreService
        .watchCollectionGroupWhere(
          collectionId: 'revisions',
          whereField: 'userId',
          isEqualTo: userId,
          whereLtEqField: 'scheduledDate',
          lessThanOrEqualTo: endOfToday,
          orderByField: 'scheduledDate',
        )
        .map((docs) => docs
            .where((d) => d['isCompleted'] == false)
            .map((d) => RevisionEntryModel.fromMap(d, d['id'] as String))
            .toList());
  }
}
