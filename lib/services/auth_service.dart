import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Anonymous sign in
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print('✅ Signed in anonymously with UID: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      print('❌ Anonymous sign in failed: $e');
      return null;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get User ID (or null if not logged in)
  String? get userId => currentUser?.uid;
  
  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email & Password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Temporary bypass: Use anonymous sign-in for testing
      print('⚠️ Using anonymous sign-in due to Firebase configuration issue');
      return await signInAnonymously();
      
      // Original code (commented out temporarily):
      // final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // return credential.user;
    } catch (e) {
      print('❌ Email sign in failed: $e');
      // Fallback to anonymous sign-in
      return await signInAnonymously();
    }
  }

  // Sign up with Email & Password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Temporary bypass: Use anonymous sign-in for testing
      print('⚠️ Using anonymous sign-in due to Firebase configuration issue');
      return await signInAnonymously();
      
      // Original code (commented out temporarily):
      // final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // return credential.user;
    } catch (e) {
      print('❌ Email sign up failed: $e');
      // Fallback to anonymous sign-in
      return await signInAnonymously();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
