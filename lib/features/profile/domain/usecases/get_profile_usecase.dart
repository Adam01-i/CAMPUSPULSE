// lib/features/profile/domain/usecases/get_profile_usecase.dart

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<ProfileEntity> call() => repository.getProfile();
}
