// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? getCurrentUser();

  Stream<User?> get authStateChanges;
}
