import 'package:study_smart/core/services/firestore_service.dart';
import 'package:study_smart/features/study_items/data/models/study_item_model.dart';

/// Firestore CRUD service scoped to study items.
///
/// This class is the single point of contact for all [StudyItemModel] Firestore
/// operations.  It delegates raw network I/O to [FirestoreService] and handles
/// path construction and model serialisation / deserialisation.
///
/// Firestore path layout
/// ─────────────────────
/// users/{uid}/decks/{deckId}/items/{itemId}
class StudyItemFirestoreService {
  StudyItemFirestoreService({required this.firestoreService});

  final FirestoreService firestoreService;

  // ── Path helpers ──────────────────────────────────────────────────────────

  static String _collectionPath(String userId, String deckId) =>
      'users/$userId/decks/$deckId/items';

  static String _documentPath(String userId, String deckId, String itemId) =>
      'users/$userId/decks/$deckId/items/$itemId';

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Persist a new study item to Firestore.
  ///
  /// The [item]'s [StudyItemModel.id], [StudyItemModel.userId] and
  /// [StudyItemModel.deckId] must already be set before calling this.
  Future<StudyItemModel> addStudyItem(StudyItemModel item) async {
    final path = _documentPath(item.userId, item.deckId, item.id);
    await firestoreService.setDocument(path: path, data: item.toMap());
    return item;
  }

  /// Fetch all study items that belong to [deckId] for the given [userId],
  /// ordered by creation date (oldest first).
  Future<List<StudyItemModel>> getStudyItems({
    required String userId,
    required String deckId,
  }) async {
    final docs = await firestoreService.getCollection(
      collectionPath: _collectionPath(userId, deckId),
      orderByField: 'createdAt',
    );
    return docs.map((d) => StudyItemModel.fromMap(d, d['id'] as String)).toList();
  }

  /// Overwrite specific fields on an existing study item.
  ///
  /// Only the fields present in [item.toMap()] are written; the document is
  /// not deleted and re-created.
  Future<void> updateStudyItem(StudyItemModel item) async {
    final path = _documentPath(item.userId, item.deckId, item.id);
    await firestoreService.updateDocument(path: path, data: item.toMap());
  }

  /// Permanently delete the study item at [itemId] inside [deckId] / [userId].
  Future<void> deleteStudyItem({
    required String userId,
    required String deckId,
    required String itemId,
  }) async {
    final path = _documentPath(userId, deckId, itemId);
    await firestoreService.deleteDocument(path);
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Real-time stream of all study items in a deck — useful for reactive UIs.
  Stream<List<StudyItemModel>> watchStudyItems({
    required String userId,
    required String deckId,
  }) {
    return firestoreService
        .watchCollection(
          collectionPath: _collectionPath(userId, deckId),
          orderByField: 'createdAt',
        )
        .map((docs) =>
            docs.map((d) => StudyItemModel.fromMap(d, d['id'] as String)).toList());
  }

  /// Real-time stream of a single study item.
  Stream<StudyItemModel?> watchStudyItem({
    required String userId,
    required String deckId,
    required String itemId,
  }) {
    return firestoreService
        .watchDocument(_documentPath(userId, deckId, itemId))
        .map((data) =>
            data == null ? null : StudyItemModel.fromMap(data, data['id'] as String));
  }

  // ── Due-review query ──────────────────────────────────────────────────────

  /// Fetch items that are due for review today (nextReviewDate ≤ now).
  ///
  /// Requires a Firestore composite index on `nextReviewDate` (ascending).
  Future<List<StudyItemModel>> getDueItems({
    required String userId,
    required String deckId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final docs = await firestoreService.getCollection(
      collectionPath: _collectionPath(userId, deckId),
      orderByField: 'nextReviewDate',
    );
    // Filter client-side for simplicity; replace with Firestore .where() for
    // large collections.
    return docs
        .where((d) => (d['nextReviewDate'] as String?) != null &&
            d['nextReviewDate']!.compareTo(now) <= 0)
        .map((d) => StudyItemModel.fromMap(d, d['id'] as String))
        .toList();
  }
}
