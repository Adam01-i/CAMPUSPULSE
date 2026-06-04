// lib/features/profile/presentation/controllers/profile_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';

class ProfileController extends StateNotifier<AsyncValue<ProfileEntity>> {
  final GetProfileUseCase _getProfile;

  ProfileController(this._getProfile) : super(const AsyncValue.loading()) {
    loadProfile();
  }

Future<void> loadProfile() async {
  state = const AsyncLoading();

  try {
    final profile = await _getProfile();
    state = AsyncData(profile);
  } catch (e) {
    state = AsyncError(e, StackTrace.current);
  }
}

  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    await loadProfile();
  }
}
