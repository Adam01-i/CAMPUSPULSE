// lib/features/profile/data/datasources/profile_remote_datasource.dart

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}
