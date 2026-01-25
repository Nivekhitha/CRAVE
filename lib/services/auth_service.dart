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
}
