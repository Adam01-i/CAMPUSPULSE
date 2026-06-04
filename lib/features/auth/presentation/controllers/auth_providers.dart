// lib/features/auth/presentation/controllers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_controller.dart';

final authRemoteDataSourceProvider =
    Provider((_) => AuthRemoteDataSourceImpl());

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

final signInUseCaseProvider = Provider(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final getCurrentUserUseCaseProvider = Provider(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    signIn: ref.watch(signInUseCaseProvider),
    signOut: ref.watch(signOutUseCaseProvider),
    getCurrentUser: ref.watch(getCurrentUserUseCaseProvider),
    authStateChanges:
        ref.watch(authRepositoryProvider).authStateChanges,
  ),
);
