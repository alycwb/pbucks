import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;
  final _uuid = const Uuid();

  AuthService(this._storage);

  Future<User?> getCurrentUser() async {
    return _storage.getCurrentUser();
  }

  Future<User?> login(String email, String password, UserRole role) async {
    // In a real app, we would validate credentials against a backend
    // For now, we'll just check if the user exists in local storage
    final users = await _storage.getUsers();
    print('Login attempt:');
    print('Email: $email');
    print('Password: $password');
    print('Role: $role');
    print('Found users: ${users.length}');
    for (var user in users) {
      print('User: ${user.email} (${user.role}) - Password: ${user.password}');
    }
    try {
      final user = users.firstWhere(
        (u) => u.email == email && u.password == password && u.role == role,
      );
      print('Login successful for user: ${user.email}');
      await _storage.setCurrentUser(user);
      return user;
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearCurrentUser();
  }

  Future<User> createParentAccount(String name, String email, String password) async {
    // In a real app, we would hash the password and store it securely
    final user = User(
      id: _uuid.v4(),
      name: name,
      email: email,
      password: password,
      role: UserRole.parent,
      pbuckBalance: 0,
    );

    await _storage.saveUser(user);
    return user;
  }

  Future<User> createChildAccount(
    String name,
    String email,
    String parentId,
    String password,
  ) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      email: email,
      password: password,
      role: UserRole.child,
      parentId: parentId,
      pbuckBalance: 0,
    );

    await _storage.saveUser(user);
    return user;
  }

  Future<bool> isEmailAvailable(String email) async {
    final users = await _storage.getUsers();
    return !users.any((user) => user.email == email);
  }
} 