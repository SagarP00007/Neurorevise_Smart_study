import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Returns the currently signed-in user, or null if unauthenticated.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Signs in with [email] and [password].
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account and Firestore profile document.
  Future<Either<Failure, UserEntity>> signUp({
    required String displayName,
    required String email,
    required String password,
  });

  /// Sends a password-reset email.
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Signs the current user out.
  Future<Either<Failure, void>> signOut();

  /// Stream of auth state changes (null = signed out).
  Stream<UserEntity?> get authStateChanges;
}
