
import 'user_model.dart';
class AuthResult {
  final bool    success;
  final String? errorMessage; 
  const AuthResult._({required this.success, this.errorMessage});
  const AuthResult.ok()              : this._(success: true);
  const AuthResult.fail(String msg)  : this._(success: false, errorMessage: msg);
}

class UserRepository {

 
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance; 
  UserRepository._internal();            

  
  final List<UserModel> _users = [
    const UserModel(username: 'susan tamboby', password: 'tae123456'),
  ];
  Future<AuthResult> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200)); 
    final trimmed = username.trim().toLowerCase();
    final found = _users.any(
      (u) => u.username.toLowerCase() == trimmed && u.password == password,
    );
    if (found) return const AuthResult.ok();
    return const AuthResult.fail('Invalid username or password. Please try again.');
  }
  Future<AuthResult> signUp(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    final trimmed = username.trim().toLowerCase();
    final alreadyExists = _users.any(
      (u) => u.username.toLowerCase() == trimmed,
    );
    if (alreadyExists) {
      return const AuthResult.fail('That username is already taken. Try another one.');
    }
    _users.add(UserModel(username: username.trim(), password: password));
    return const AuthResult.ok();
  }
  Future<AuthResult> verifyUsername(String username) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final trimmed = username.trim().toLowerCase();
    final exists = _users.any((u) => u.username.toLowerCase() == trimmed);
    if (exists) return const AuthResult.ok();
    return const AuthResult.fail('No account found with that username.');
  }
  Future<AuthResult> resetPassword(String username, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final trimmed = username.trim().toLowerCase();
    final index = _users.indexWhere(
      (u) => u.username.toLowerCase() == trimmed,
    );
    if (index == -1) {
      return const AuthResult.fail('Username not found.');
    }
    _users[index] = _users[index].copyWith(password: newPassword);
    return const AuthResult.ok();
  }
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your username';
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
