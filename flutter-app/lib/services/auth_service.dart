import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Authentication service for handling anonymous login
/// Follows Clean Architecture principles with proper error handling
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Stream of authentication state changes
  /// Returns the current User if authenticated, null otherwise
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Current user if authenticated
  User? get currentUser => _auth.currentUser;
  
  /// Check if user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  /// Sign in anonymously
  /// 
  /// Returns the [UserCredential] if successful
  /// Throws [AuthException] if authentication fails
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown_error',
        message: 'An unexpected error occurred during authentication',
        originalError: e,
      );
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'signout_error',
        message: 'Failed to sign out',
        originalError: e,
      );
    }
  }
  
  /// Handle Firebase Auth exceptions and convert to user-friendly messages
  AuthException _handleAuthException(FirebaseAuthException e) {
    String userMessage;
    
    switch (e.code) {
      case 'network-request-failed':
        userMessage = 'Network error. Please check your internet connection.';
        break;
      case 'too-many-requests':
        userMessage = 'Too many requests. Please try again later.';
        break;
      case 'operation-not-allowed':
        userMessage = 'Anonymous authentication is not enabled. Please contact support.';
        break;
      case 'internal-error':
        userMessage = 'An internal error occurred. Please try again.';
        break;
      default:
        userMessage = 'Authentication failed. Please try again.';
    }
    
    return AuthException(
      code: e.code,
      message: userMessage,
      originalError: e,
    );
  }
}

/// Custom exception class for authentication errors
/// Provides user-friendly error messages
class AuthException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;
  
  AuthException({
    required this.code,
    required this.message,
    this.originalError,
  });
  
  @override
  String toString() => message;
}

