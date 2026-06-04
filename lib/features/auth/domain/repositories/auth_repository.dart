// lib/features/auth/domain/repositories/auth_repository.dart

import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  AuthUserEntity? getCurrentUser();

  Stream<AuthUserEntity?> get authStateChanges;
}
