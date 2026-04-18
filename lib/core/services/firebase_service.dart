import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central wrapper around Firebase services.
/// Register as a lazy singleton in GetIt — use [FirebaseService.instance]
/// or inject via DI.
class FirebaseService {
  FirebaseService._({
    required this.auth,
    required this.firestore,
    required this.secureStorage,
  });

  factory FirebaseService.instance() => FirebaseService._(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        secureStorage: const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
      );

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FlutterSecureStorage secureStorage;

  // ── Firestore collection references ────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> decksCollection(String uid) =>
      firestore.collection('users').doc(uid).collection('decks');

  CollectionReference<Map<String, dynamic>> studyItemsCollection(
          String uid, String deckId) =>
      firestore
          .collection('users')
          .doc(uid)
          .collection('decks')
          .doc(deckId)
          .collection('items');

  CollectionReference<Map<String, dynamic>> reviewsCollection(String uid) =>
      firestore.collection('users').doc(uid).collection('reviews');

  CollectionReference<Map<String, dynamic>> sessionsCollection(String uid) =>
      firestore.collection('users').doc(uid).collection('sessions');
}
