// lib/features/profile/presentation/controllers/profile_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_remote_datasource_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_controller.dart';
import '../../domain/entities/profile_entity.dart';

final profileRemoteDataSourceProvider =
    Provider((_) => ProfileRemoteDataSourceImpl());

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider)),
);

final getProfileUseCaseProvider = Provider(
  (ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)),
);

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileEntity>>(
  (ref) => ProfileController(
    ref.watch(getProfileUseCaseProvider),
  ),
);