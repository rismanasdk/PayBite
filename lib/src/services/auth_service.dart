import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  late final FirebaseFirestore _firestore;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
    _firestore = FirebaseFirestore.instance;
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        final displayName = googleUser.displayName ?? 'User';
        
        // Update Firebase Auth displayName if not set
        if (userCredential.user!.displayName == null ||
            userCredential.user!.displayName!.isEmpty) {
          try {
            await userCredential.user!.updateDisplayName(displayName);
            await userCredential.user!.reload();
          } catch (e) {
            print('Error updating displayName in Firebase Auth: $e');
          }
        }

        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // First time login - create new user with role 'user'
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'displayName': displayName,
            'photoURL': userCredential.user!.photoURL,
            'role': 'user', // Default role for new users
            'lastLogin': FieldValue.serverTimestamp(),
            'lastActivity': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Existing user - only update lastLogin and lastActivity, DO NOT touch role
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({
            'lastLogin': FieldValue.serverTimestamp(),
            'lastActivity': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Test Mode: Anonymous Sign In (for development/testing)
  Future<UserCredential?> signInAsTestAdmin() async {
    try {
      final userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': 'admin@test.local',
          'displayName': 'Test Admin',
          'role': 'admin',
          'isTestMode': true,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print('Error test sign in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      SessionManager().stopSessionMonitoring();
      SessionManager().resetSession();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Start session monitoring after login
  void startSessionMonitoring() {
    // Set callback for when session times out
    SessionManager().setSessionTimeoutCallback(_handleSessionTimeout);
    SessionManager().startSessionMonitoring();
  }

  // Handle session timeout with complete logout
  Future<void> _handleSessionTimeout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during session timeout logout: $e');
    }
  }

  // Get user role
  Future<String> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['role'] as String? ?? 'user';
      }
      return 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    final role = await getUserRole(userId);
    return role == 'admin';
  }

  // Set user as admin (only for admin operations)
  Future<void> setUserAsAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
      });
    } catch (e) {
      print('Error setting user as admin: $e');
    }
  }
}
