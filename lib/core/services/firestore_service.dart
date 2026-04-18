import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_smart/core/errors/exceptions.dart';
import 'package:study_smart/core/services/firebase_service.dart';

/// Generic Firestore helpers. Inject FirebaseService; call typed methods.
/// Each feature's datasource composes this service rather than touching
/// FirebaseFirestore.instance directly.
class FirestoreService {
  FirestoreService({required this.firebaseService});

  final FirebaseService firebaseService;

  FirebaseFirestore get _db => firebaseService.firestore;

  // ── Generic CRUD ──────────────────────────────────────────────────────────

  /// Sets (creates or overwrites) a document at [path].
  Future<void> setDocument({
    required String path,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      await _db.doc(path).set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore write error');
    }
  }

  /// Updates specific fields in a document at [path].
  Future<void> updateDocument({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.doc(path).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore update error');
    }
  }

  /// Deletes a document at [path].
  Future<void> deleteDocument(String path) async {
    try {
      await _db.doc(path).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore delete error');
    }
  }

  /// Fetches a single document at [path]. Returns null if it doesn't exist.
  Future<Map<String, dynamic>?> getDocument(String path) async {
    try {
      final snap = await _db.doc(path).get();
      return snap.exists ? snap.data() : null;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore read error');
    }
  }

  /// Fetches all documents from a [collectionPath] (optionally ordered/filtered).
  Future<List<Map<String, dynamic>>> getCollection({
    required String collectionPath,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collectionPath);
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      if (limit != null) query = query.limit(limit);
      final snap = await query.get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore collection error');
    }
  }

  /// Fetches documents from [collectionPath] matching [whereField] == [isEqualTo].
  /// Much more efficient than getting the full collection and filtering locally.
  Future<List<Map<String, dynamic>>> getCollectionWhere({
    required String collectionPath,
    required String whereField,
    required Object isEqualTo,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collectionPath)
          .where(whereField, isEqualTo: isEqualTo);
          
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }
      if (limit != null) query = query.limit(limit);
      
      final snap = await query.get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore filtered collection error');
    }
  }

  /// Returns a real-time stream of a document at [path].
  Stream<Map<String, dynamic>?> watchDocument(String path) {
    return _db.doc(path).snapshots().map(
          (snap) => snap.exists ? snap.data() : null,
        );
  }

  /// Returns a real-time stream of a collection at [collectionPath].
  Stream<List<Map<String, dynamic>>> watchCollection({
    required String collectionPath,
    String? orderByField,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(collectionPath);
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    return query.snapshots().map(
          (snap) =>
              snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  /// Returns a real-time stream across all collections named [collectionId].
  Stream<List<Map<String, dynamic>>> watchCollectionGroup({
    required String collectionId,
    String? orderByField,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = _db.collectionGroup(collectionId);
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    return query.snapshots().map(
          (snap) =>
              snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  /// Server-side filtered collection group stream.
  ///
  /// Applies up to three optional `where` filters before ordering, so Firestore
  /// only delivers matching documents — no client-side scan needed.
  ///
  /// Requires a composite Firestore index when combining multiple fields.
  /// Suggested index for due revisions: `userId ASC, scheduledDate ASC`.
  Stream<List<Map<String, dynamic>>> watchCollectionGroupWhere({
    required String collectionId,
    String? whereField,
    Object? isEqualTo,
    String? whereLtEqField,        // field for <= filter  (e.g. scheduledDate)
    Object? lessThanOrEqualTo,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db.collectionGroup(collectionId);

    // equality filter (e.g. userId == uid)
    if (whereField != null && isEqualTo != null) {
      query = query.where(whereField, isEqualTo: isEqualTo);
    }
    // range filter (e.g. scheduledDate <= endOfToday)
    if (whereLtEqField != null && lessThanOrEqualTo != null) {
      query = query.where(whereLtEqField, isLessThanOrEqualTo: lessThanOrEqualTo);
    }
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(
          (snap) =>
              snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // ── Batch & Transaction helpers ───────────────────────────────────────────

  /// Executes multiple writes atomically.
  Future<void> runBatch(
      Future<void> Function(WriteBatch batch) operations) async {
    final batch = _db.batch();
    try {
      await operations(batch);
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore batch error');
    }
  }

  /// Runs a Firestore transaction.
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction txn) handler) async {
    try {
      return await _db.runTransaction(handler);
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firestore transaction error');
    }
  }

  // ── Path helpers ──────────────────────────────────────────────────────────
  static String userPath(String uid) => 'users/$uid';
  static String deckPath(String uid, String deckId) =>
      'users/$uid/decks/$deckId';
  static String itemPath(String uid, String deckId, String itemId) =>
      'users/$uid/decks/$deckId/items/$itemId';
  static String reviewPath(String uid, String itemId) =>
      'users/$uid/reviews/$itemId';
  static String sessionPath(String uid, String sessionId) =>
      'users/$uid/sessions/$sessionId';
}
