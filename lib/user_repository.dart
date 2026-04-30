// lib/user_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult._({required this.success, this.errorMessage});
  const AuthResult.ok() : this._(success: true);
  const AuthResult.fail(String msg) : this._(success: false, errorMessage: msg);
}

class UserRepository {
  static UserRepository? _instance;
  static FirebaseAuth? _authInstance;
  static FirebaseFirestore? _dbInstance;

  factory UserRepository() {
    _instance ??= UserRepository._internal();
    return _instance!;
  }
  UserRepository._internal();

  static Future<void> initializeFirebase() async {
    _authInstance = FirebaseAuth.instance;
    _dbInstance = FirebaseFirestore.instance;
  }

  FirebaseAuth get _auth {
    return _authInstance ?? FirebaseAuth.instance;
  }

  FirebaseFirestore get _db {
    return _dbInstance ?? FirebaseFirestore.instance;
  }

  String? _currentUsername;
  String? get currentUsername => _currentUsername;

Future<AuthResult> login(String username, String password) async {
    final trimmed = username.trim().toLowerCase();
    
    try {
      // Query Firestore for user
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: trimmed)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return const AuthResult.fail('Username not found.');
      }

      final email = query.docs.first['email'] as String;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _currentUsername = username.trim();
      return const AuthResult.ok();
    } catch (e) {
      return AuthResult.fail('Login failed. Check your credentials.');
    }
  }

  Future<AuthResult> signUp(String username, String password) async {
    try {
      final trimmed = username.trim().toLowerCase();

      final existing = await _db
          .collection('users')
          .where('username', isEqualTo: trimmed)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return const AuthResult.fail(
            'That username is already taken. Try another one.');
      }

      final email = '$trimmed@studybuddy.app';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'username': trimmed,
        'displayName': username.trim(),
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUsername = username.trim();
      return const AuthResult.ok();
    } catch (e) {
      return AuthResult.fail('Sign up failed. Try a different username.');
    }
  }

  void logout() {
    _auth.signOut();
    _currentUsername = null;
  }

  Future<AuthResult> verifyUsername(String username) async {
    try {
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return const AuthResult.fail('No account found with that username.');
      }
      return const AuthResult.ok();
    } catch (_) {
      return const AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> resetPassword(String username, String newPassword) async {
    try {
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return const AuthResult.fail('Username not found.');
      }

      final email = query.docs.first['email'] as String;

      await _auth.sendPasswordResetEmail(email: email);

      return const AuthResult.ok();
    } catch (_) {
      return const AuthResult.fail(
          'Could not reset password. Please try again.');
    }
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }
    if (value.trim().length < 2) return 'Username is too short';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a new password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  
}
