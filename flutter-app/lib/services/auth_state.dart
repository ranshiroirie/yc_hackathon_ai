import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'auth_service.dart';

/// Authentication state management
/// Provides a stream of authentication state changes
class AuthState {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;
  
  // StreamController for auth state
  final _authStateController = StreamController<AuthStateStatus>.broadcast();
  
  AuthState(this._authService) {
    _initializeAuthState();
  }
  
  /// Stream of authentication state status
  Stream<AuthStateStatus> get authStateStream => _authStateController.stream;
  
  /// Current authentication status
  AuthStateStatus _currentStatus = AuthStateStatus.unknown;
  AuthStateStatus get currentStatus => _currentStatus;
  
  /// Current user if authenticated
  User? get currentUser => _authService.currentUser;
  
  /// Sign in anonymously
  /// 
  /// Returns the [UserCredential] if successful
  /// Throws [AuthException] if authentication fails
  Future<UserCredential> signInAnonymously() async {
    return await _authService.signInAnonymously();
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    await _authService.signOut();
  }
  
  /// Initialize auth state listener
  void _initializeAuthState() {
    _authSubscription = _authService.authStateChanges.listen(
      (User? user) {
        final newStatus = user != null 
            ? AuthStateStatus.authenticated 
            : AuthStateStatus.unauthenticated;
        
        if (_currentStatus != newStatus) {
          _currentStatus = newStatus;
          _authStateController.add(newStatus);
        }
      },
      onError: (error) {
        _authStateController.addError(error);
      },
    );
  }
  
  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }
}

/// Authentication state status enum
enum AuthStateStatus {
  unknown,
  authenticated,
  unauthenticated,
}

