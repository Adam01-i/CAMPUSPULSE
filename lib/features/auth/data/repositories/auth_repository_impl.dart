// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthUserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  @override
  AuthUserEntity? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();
    return user != null ? _mapUser(user) : null;
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges =>
      remoteDataSource.authStateChanges.map(
        (user) => user != null ? _mapUser(user) : null,
      );

  AuthUserEntity _mapUser(User user) => AuthUserEntity(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

  Exception _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Aucun compte trouvé pour cet email.');
      case 'wrong-password':
        return Exception('Mot de passe incorrect.');
      case 'invalid-email':
        return Exception('Adresse email invalide.');
      case 'user-disabled':
        return Exception('Ce compte a été désactivé.');
      case 'too-many-requests':
        return Exception(
            'Trop de tentatives. Réessayez dans quelques minutes.');
      case 'network-request-failed':
        return Exception('Erreur réseau. Vérifiez votre connexion.');
      default:
        return Exception('Erreur de connexion. Veuillez réessayer.');
    }
  }
}
