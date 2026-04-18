import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_smart/features/auth/domain/entities/user_entity.dart';

/// Data Transfer Object — converts between Firebase User and domain UserEntity,
/// and between Firestore Map and the model.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.createdAt,
    required super.isEmailVerified,
  });

  // ── From Firebase Auth User ───────────────────────────────────────────────
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      isEmailVerified: user.emailVerified,
    );
  }

  // ── From Firestore document ───────────────────────────────────────────────
  factory UserModel.fromFirestore(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(
          map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
    );
  }

  // ── To Firestore document ─────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
