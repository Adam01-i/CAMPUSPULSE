// lib/features/auth/domain/usecases/sign_in_usecase.dart

import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AuthUserEntity> call({
    required String email,
    required String password,
  }) =>
      repository.signIn(email: email, password: password);
}
