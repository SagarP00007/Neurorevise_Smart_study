import 'package:dartz/dartz.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/core/utils/use_case.dart';
import 'package:study_smart/features/auth/domain/entities/user_entity.dart';
import 'package:study_smart/features/auth/domain/repositories/auth_repository.dart';

// ── Sign In ───────────────────────────────────────────────────────────────────
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  SignInUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) =>
      repository.signIn(email: params.email, password: params.password);
}

class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
}

// ── Sign Up ───────────────────────────────────────────────────────────────────
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  SignUpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) =>
      repository.signUp(
        displayName: params.displayName,
        email: params.email,
        password: params.password,
      );
}

class SignUpParams {
  final String displayName;
  final String email;
  final String password;
  const SignUpParams({
    required this.displayName,
    required this.email,
    required this.password,
  });
}

// ── Sign Out ──────────────────────────────────────────────────────────────────
class SignOutUseCase implements UseCase<void, NoParams> {
  SignOutUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.signOut();
}

// ── Get Current User ──────────────────────────────────────────────────────────
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) =>
      repository.getCurrentUser();
}

// ── Password Reset ────────────────────────────────────────────────────────────
class SendPasswordResetEmailUseCase implements UseCase<void, String> {
  SendPasswordResetEmailUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(String email) =>
      repository.sendPasswordResetEmail(email);
}
