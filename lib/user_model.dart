class UserModel {
  final String uid;
  final String username;
  final String password;

  const UserModel({
    required this.uid,
    required this.username,
    required this.password,
  });
  UserModel copyWith({String? uid, String? username, String? password}) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'UserModel(username: $username)';
}
