
class UserModel {
  final String username;
  final String password;

  const UserModel({
    required this.username,
    required this.password,
  });
  UserModel copyWith({String? username, String? password}) {
    return UserModel(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
  @override
  String toString() => 'UserModel(username: $username)';
}
