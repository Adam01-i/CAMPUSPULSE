// lib/features/auth/domain/entities/auth_user_entity.dart

class AuthUserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AuthUserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
