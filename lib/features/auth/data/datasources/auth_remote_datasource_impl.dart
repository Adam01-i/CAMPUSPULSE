// lib/features/auth/data/datasources/auth_remote_datasource_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
