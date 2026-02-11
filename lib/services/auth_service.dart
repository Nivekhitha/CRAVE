import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth? _auth;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      // Check if Firebase is initialized
      Firebase.app();
      _auth = FirebaseAuth.instance;
      debugPrint('✅ AuthService initialized with Firebase');
    } catch (e) {
      debugPrint('⚠️ AuthService: Firebase not available: $e');
      _auth = null;
    }
  }

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Get User ID (or null if not logged in)
  String? get userId => currentUser?.uid;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? Stream.value(null);

  // Check if user is anonymous
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  // Get user email (null for anonymous users)
  String? get userEmail => currentUser?.email;

  // Check if Firebase Auth is available
  bool get isAvailable => _auth != null;

  // Sign up with Email & Password
  Future<AuthResult> signUpWithEmailAndPassword(
      String email, String password) async {
    if (_auth == null) {
      return AuthResult.error('Authentication service not available');
    }
    
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      debugPrint('✅ Email sign up successful: ${credential.user?.email}');
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Email sign up failed: ${e.code} - ${e.message}');
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected sign up error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  // Sign in with Email & Password
  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    if (_auth == null) {
      return AuthResult.error('Authentication service not available');
    }
    
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      debugPrint('✅ Email sign in successful: ${credential.user?.email}');
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Email sign in failed: ${e.code} - ${e.message}');
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected sign in error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  // Anonymous sign in (fallback/guest option)
  Future<AuthResult> signInAnonymously() async {
    if (_auth == null) {
      return AuthResult.error('Authentication service not available');
    }
    
    try {
      final userCredential = await _auth!.signInAnonymously();
      debugPrint(
          '✅ Signed in anonymously with UID: ${userCredential.user?.uid}');
      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Anonymous sign in failed: ${e.code} - ${e.message}');
      return AuthResult.error('Unable to continue as guest. Please try again.');
    } catch (e) {
      debugPrint('❌ Unexpected anonymous sign in error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (_auth == null) {
      debugPrint('⚠️ Auth service not available for sign out');
      return;
    }
    
    try {
      await _auth!.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      return AuthResult.error('Authentication service not available');
    }
    
    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ Password reset email sent to: $email');
      return AuthResult.success(null, message: 'Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset failed: ${e.code} - ${e.message}');
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected password reset error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  // Convert anonymous account to email/password
  Future<AuthResult> linkAnonymousWithEmailPassword(
      String email, String password) async {
    if (_auth == null) {
      return AuthResult.error('Authentication service not available');
    }
    
    try {
      if (currentUser == null || !currentUser!.isAnonymous) {
        return AuthResult.error('No anonymous user to link');
      }

      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      final userCredential = await currentUser!.linkWithCredential(credential);

      debugPrint('✅ Anonymous account linked with email: $email');
      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Account linking failed: ${e.code} - ${e.message}');
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('❌ Unexpected linking error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  // Helper method to convert Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// Result wrapper for better error handling
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? message;

  AuthResult.success(this.user, {this.message})
      : isSuccess = true,
        error = null;

  AuthResult.error(this.error)
      : isSuccess = false,
        user = null,
        message = null;
}
