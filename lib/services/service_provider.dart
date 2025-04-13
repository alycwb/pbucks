import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import 'auth_service.dart';
import 'task_service.dart';
import 'reward_service.dart';

class ServiceProvider {
  late final StorageService storage;
  late final AuthService auth;
  late final TaskService tasks;
  late final RewardService rewards;

  static ServiceProvider? _instance;

  ServiceProvider._();

  static Future<ServiceProvider> getInstance() async {
    if (_instance == null) {
      _instance = ServiceProvider._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    auth = AuthService(storage);
    tasks = TaskService(storage);
    rewards = RewardService(storage);
  }
} 