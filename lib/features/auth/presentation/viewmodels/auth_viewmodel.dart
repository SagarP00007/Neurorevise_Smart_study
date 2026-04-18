import 'package:flutter/foundation.dart';
import 'package:study_smart/core/errors/failures.dart';
import 'package:study_smart/core/utils/use_case.dart';
import 'package:study_smart/features/auth/domain/entities/user_entity.dart';
import 'package:study_smart/features/auth/domain/usecases/auth_usecases.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.sendPasswordResetEmailUseCase,
  });

  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;

  AuthState _state = AuthState.idle;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _currentUser != null;

  // ── Load current user on app start ────────────────────────────────────────
  Future<void> loadCurrentUser() async {
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) => _setError(failure),
      (user) {
        _currentUser = user;
        _setState(AuthState.idle);
      },
    );
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<void> signIn({required String email, required String password}) async {
    _setState(AuthState.loading);
    final result = await signInUseCase(
      SignInParams(email: email, password: password),
    );
    result.fold(
      (failure) => _setError(failure),
      (user) {
        _currentUser = user;
        _setState(AuthState.success);
      },
    );
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  Future<void> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    final result = await signUpUseCase(
      SignUpParams(
          displayName: displayName, email: email, password: password),
    );
    result.fold(
      (failure) => _setError(failure),
      (user) {
        _currentUser = user;
        _setState(AuthState.success);
      },
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    _setState(AuthState.loading);
    final result = await signOutUseCase(const NoParams());
    result.fold(
      (failure) => _setError(failure),
      (_) {
        _currentUser = null;
        _setState(AuthState.idle);
      },
    );
  }

  // ── Password Reset ─────────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    _setState(AuthState.loading);
    final result = await sendPasswordResetEmailUseCase(email);
    result.fold(
      (failure) => _setError(failure),
      (_) => _setState(AuthState.success),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setError(Failure failure) {
    _errorMessage = failure.message;
    _setState(AuthState.error);
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _setState(AuthState.idle);
  }
}
