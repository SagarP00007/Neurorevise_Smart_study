import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_smart/core/errors/exceptions.dart';
import 'package:study_smart/core/services/firebase_service.dart';
import 'package:study_smart/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String displayName,
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({required this.firebaseService});

  final FirebaseService firebaseService;

  FirebaseAuth get _auth => firebaseService.auth;

  // ── Current User ──────────────────────────────────────────────────────────
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  @override
  Future<UserModel> signIn(
      {required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  @override
  Future<UserModel> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Update display name
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();

      final userModel =
          UserModel.fromFirebaseUser(_auth.currentUser!);

      // 3. Create Firestore profile document
      await firebaseService.usersCollection
          .doc(userModel.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw ServerException(
          message: 'Firestore Access Denied: Enable Firestore and check your Rules in Firebase Console.',
        );
      }
      throw ServerException(message: 'Database Error (${e.code}): ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected Error: $e');
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Auth State Stream ─────────────────────────────────────────────────────
  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map(
          (user) =>
              user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }

  // ── Error Mapping ─────────────────────────────────────────────────────────
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password auth is not enabled in Firebase Console.';
      case 'invalid-api-key':
        return 'Firebase configuration is invalid. Run flutterfire configure.';
      default:
        return 'Auth Failed ($code). Enable this in Firebase Console or search ($code).';
    }
  }
}
