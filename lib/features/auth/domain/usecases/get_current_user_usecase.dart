// lib/features/auth/domain/usecases/get_current_user_usecase.dart

import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  AuthUserEntity? call() => repository.getCurrentUser();
}
