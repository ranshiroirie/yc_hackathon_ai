import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:homii_ai_event_comp_app/services/auth_service.dart';

part 'auth_provider.g.dart';

/// Provider for AuthService
@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}

/// Provider for current Firebase Auth user stream
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

/// Provider for current authenticated user
@riverpod
User? currentUser(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
}

/// Provider for authentication status
@riverpod
Stream<AuthStateStatus> authStateStatus(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((user) {
    if (user == null) {
      return AuthStateStatus.unauthenticated;
    }
    return AuthStateStatus.authenticated;
  });
}

/// Provider for checking if user is authenticated
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

/// Authentication state status enum
enum AuthStateStatus {
  unknown,
  authenticated,
  unauthenticated,
}

/// Provider for anonymous sign in
@riverpod
class AnonymousSignIn extends _$AnonymousSignIn {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  /// Sign in anonymously
  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Provider for sign out
@riverpod
class SignOut extends _$SignOut {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

