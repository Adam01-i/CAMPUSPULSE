// lib/features/profile/presentation/controllers/profile_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';

class ProfileController
    extends StateNotifier<AsyncValue<ProfileEntity>> {
  final GetProfileUseCase _getProfile;

  ProfileController(this._getProfile)
      : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await _getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
