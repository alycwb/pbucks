import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/reward.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _tasksKey = 'tasks';
  static const String _rewardsKey = 'rewards';
  static const String _currentUserKey = 'currentUser';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // User Methods
  Future<void> saveUser(User user) async {
    print('Saving user: ${user.email} with password: ${user.password}');
    final users = await getUsers();
    users.removeWhere((u) => u.id == user.id);
    users.add(user);
    final jsonData = users.map((u) => u.toJson()).toList();
    print('All users after save: $jsonData');
    await _prefs.setString(_usersKey, jsonEncode(jsonData));
  }

  Future<List<User>> getUsers() async {
    final usersJson = _prefs.getString(_usersKey);
    if (usersJson == null) return [];

    final List<dynamic> usersList = jsonDecode(usersJson);
    print('Current users in storage:');
    for (var user in usersList) {
      print('Email: ${user['email']}, Role: ${user['role']}, Password: ${user['password']}');
    }
    return usersList.map((json) => User.fromJson(json)).toList();
  }

  Future<User?> getUserById(String id) async {
    final users = await getUsers();
    return users.firstWhere((u) => u.id == id);
  }

  Future<List<User>> getChildrenForParent(String parentId) async {
    final users = await getUsers();
    return users.where((u) => u.parentId == parentId).toList();
  }

  Future<void> setCurrentUser(User user) async {
    await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    final String? userJson = _prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_currentUserKey);
  }

  // Task Methods
  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == task.id);
    tasks.add(task);
    await _prefs.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<List<Task>> getTasks() async {
    final String? tasksJson = _prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    final List<dynamic> tasksList = jsonDecode(tasksJson);
    return tasksList.map((json) => Task.fromJson(json)).toList();
  }

  Future<List<Task>> getTasksForChild(String childId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.childIds.contains(childId)).toList();
  }

  Future<List<Task>> getTasksForParent(String parentId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.parentId == parentId).toList();
  }

  // Reward Methods
  Future<void> saveReward(Reward reward) async {
    final rewards = await getRewards();
    rewards.removeWhere((r) => r.id == reward.id);
    rewards.add(reward);
    await _prefs.setString(_rewardsKey, jsonEncode(rewards.map((r) => r.toJson()).toList()));
  }

  Future<List<Reward>> getRewards() async {
    final String? rewardsJson = _prefs.getString(_rewardsKey);
    if (rewardsJson == null) return [];
    final List<dynamic> rewardsList = jsonDecode(rewardsJson);
    return rewardsList.map((json) => Reward.fromJson(json)).toList();
  }

  Future<List<Reward>> getRewardsForParent(String parentId) async {
    final rewards = await getRewards();
    return rewards.where((r) => r.parentId == parentId).toList();
  }

  // Clear all data (for testing or logout)
  Future<void> clearAll() async {
    await clearCurrentUser();
  }

  Future<void> clearStorage() async {
    await clearCurrentUser();
  }

  // Add test children for development
  Future<void> addTestChildren(String parentId) async {
    final testChildren = [
      User(
        id: 'child1',
        name: 'João Silva',
        email: 'joao@test.com',
        role: UserRole.child,
        parentId: parentId,
        password: '123456',
      ),
      User(
        id: 'child2',
        name: 'Maria Santos',
        email: 'maria@test.com',
        role: UserRole.child,
        parentId: parentId,
        password: '123456',
      ),
      User(
        id: 'child3',
        name: 'Pedro Oliveira',
        email: 'pedro@test.com',
        role: UserRole.child,
        parentId: parentId,
        password: '123456',
      ),
      User(
        id: 'child4',
        name: 'Ana Costa',
        email: 'ana@test.com',
        role: UserRole.child,
        parentId: parentId,
        password: '123456',
      ),
      User(
        id: 'child5',
        name: 'Lucas Ferreira',
        email: 'lucas@test.com',
        role: UserRole.child,
        parentId: parentId,
        password: '123456',
      ),
    ];

    final users = await getUsers();

    // Add test children if they don't exist
    for (final child in testChildren) {
      if (!users.any((u) => u.email == child.email)) {
        users.add(child);
      }
    }

    await _prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }
} 