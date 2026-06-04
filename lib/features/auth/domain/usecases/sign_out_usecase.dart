// lib/features/auth/domain/usecases/sign_out_usecase.dart

import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() => repository.signOut();
}
