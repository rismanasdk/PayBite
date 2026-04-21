import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  final Duration inactivityTimeout = const Duration(hours: 1); // 1 minute for testing, change to Duration(hours: 1) for production
  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  /// Start session monitoring for the current user
  void startSessionMonitoring() {
    _lastActivityTime = DateTime.now();
    _resetInactivityTimer();
  }

  /// Stop session monitoring
  void stopSessionMonitoring() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Update user activity (should be called on user interaction)
  Future<void> recordUserActivity() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _lastActivityTime = DateTime.now();
      _resetInactivityTimer();

      // Update lastActivity in Firestore
      await _firestore.collection('users').doc(userId).update({
        'lastActivity': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording user activity: $e');
    }
  }

  /// Reset the inactivity timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () {
      _handleSessionTimeout();
    });
  }

  /// Handle session timeout - force logout
  Future<void> _handleSessionTimeout() async {
    print('Session timeout - logging out user due to inactivity');
    stopSessionMonitoring();

    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during forced logout: $e');
    }
  }

  /// Check if user session is still valid
  bool isSessionValid() {
    if (_lastActivityTime == null) return false;

    final timeSinceLastActivity = DateTime.now().difference(_lastActivityTime!);
    return timeSinceLastActivity < inactivityTimeout;
  }

  /// Get remaining session time in seconds
  int getRemainingSessionSeconds() {
    if (_lastActivityTime == null) return 0;

    final timeSinceLastActivity = DateTime.now().difference(_lastActivityTime!);
    final remaining =
        inactivityTimeout.inSeconds - timeSinceLastActivity.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Check and validate session from Firestore
  Future<bool> validateSessionFromFirestore(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return false;
      }

      final lastActivity = userDoc.data()?['lastActivity'] as Timestamp?;
      if (lastActivity == null) {
        return true; // Allow if no lastActivity recorded yet
      }

      final timeSinceLastActivity =
          DateTime.now().difference(lastActivity.toDate());

      if (timeSinceLastActivity > inactivityTimeout) {
        // Session expired
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating session: $e');
      return true; // Allow on error to prevent false logouts
    }
  }

  /// Reset session on manual logout
  Future<void> resetSession() async {
    stopSessionMonitoring();
    _lastActivityTime = null;
  }
}
