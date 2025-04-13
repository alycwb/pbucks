enum UserRole { parent, child }

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? parentId;
  double pbuckBalance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.parentId,
    this.pbuckBalance = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == 'UserRole.${json['role']}',
      ),
      parentId: json['parentId'],
      pbuckBalance: json['pbuckBalance']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
      'parentId': parentId,
      'pbuckBalance': pbuckBalance,
    };
  }
} 