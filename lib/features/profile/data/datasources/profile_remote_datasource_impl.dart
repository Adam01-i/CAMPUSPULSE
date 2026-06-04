// lib/features/profile/data/datasources/profile_remote_datasource_impl.dart

import '../models/profile_model.dart';
import 'profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileModel> getProfile() async {
    // Délai simulé — remplacer par un vrai appel Dio/Firebase plus tard
    await Future.delayed(const Duration(seconds: 1));

    return ProfileModel.fromJson({
      'id': 'usr_001',
      'first_name': 'Awa',
      'last_name': 'Seck',
      'email': 'adama.seck@uad.edu.sn',
      'student_id': 'SI20250021',
      'department': 'TIC',
      'program': 'Master Systèmes d\'Information',
      'level': 'Master 1',
      'avatar_url': null,
      'is_active': true,
    });
  }
}
