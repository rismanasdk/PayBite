import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  late final FirebaseFirestore _firestore;
  bool _isInitialized = false;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn(
      clientId:
          '125155915973-l6facmirjonndni6jlnc80brqqfjejm1.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
    _firestore = FirebaseFirestore.instance;
  }

  // Initialize Google Sign In once
  Future<void> _initializeGoogleSignIn() async {
    if (!_isInitialized) {
      try {
        await _googleSignIn.signOut(); // Clear previous session
        _isInitialized = true;
      } catch (e) {
        print('Error initializing Google Sign In: $e');
      }
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In - with improved web support
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web, use Firebase Auth's signInWithPopup which is more reliable
      GoogleAuthProvider authProvider = GoogleAuthProvider()
        ..setCustomParameters({
          'prompt': 'select_account', // Show account picker
          'display': 'popup', // Use popup mode
        });

      // Try Firebase Auth popup first (more reliable on web)
      try {
        final userCredential = await _auth.signInWithPopup(authProvider);
        await _handleSignInSuccess(userCredential);
        return userCredential;
      } catch (e) {
        // If popup fails, try redirect method
        print('Popup failed, trying redirect method: $e');
        if (e.toString().contains('popup_blocked') ||
            e.toString().contains('popup_closed')) {
          // Fallback to redirect
          await _auth.signInWithRedirect(authProvider);
          return null; // Redirect handles navigation
        }
        rethrow;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Handle successful sign in
  Future<void> _handleSignInSuccess(UserCredential userCredential) async {
    if (userCredential.user != null) {
      final displayName = userCredential.user!.displayName ?? 'User';

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
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
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
      _isInitialized = false; // Reset initialization flag
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
      _isInitialized = false;
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
