// lib/features/auth/presentation/controllers/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/fcm_service.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

// ─── État ────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Controller ──────────────────────────────
class AuthController extends StateNotifier<AuthState> {
  final SignInUseCase signIn;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final Stream<AuthUserEntity?> authStateChanges;

  AuthController({
    required this.signIn,
    required this.signOut,
    required this.getCurrentUser,
    required this.authStateChanges,
  }) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    // Écoute les changements d'état Firebase en temps réel
    authStateChanges.listen((user) {
      if (user != null) {
        state = AuthAuthenticated(user);
        _registerFcmToken(user.uid);
      } else {
        state = const AuthUnauthenticated();
      }
    });
  }

  Future<void> _registerFcmToken(String userId) async {
    try {
      await FCMService.init(userId);
    } catch (_) {
      // Token registration must not block auth flow.
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await signIn(email: email, password: password);
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await signOut();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}
