import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/parent/manage_tasks_screen.dart';
import 'screens/parent/manage_children_screen.dart';
import 'screens/parent/parent_dashboard.dart';
import 'screens/parent/manage_rewards_screen.dart';
import 'screens/child/child_dashboard.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/task_service.dart';
import 'services/reward_service.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  final auth = AuthService(storage);
  final tasks = TaskService(storage);
  final rewards = RewardService(storage);

  // Ensure we have a parent account for testing
  final testParent = await auth.login('test@example.com', 'password123', UserRole.parent);
  if (testParent == null) {
    await auth.createParentAccount(
      'Test Parent',
      'test@example.com',
      'password123',
    );
    final parent = await auth.login('test@example.com', 'password123', UserRole.parent);
    if (parent != null) {
      await storage.addTestChildren(parent.id);
      
      // Create test tasks
      final children = await storage.getChildrenForParent(parent.id);
      if (children.isNotEmpty) {
        await tasks.createTask(
          title: 'Clean your room',
          description: 'Make your bed and organize your toys',
          pbuckValue: 50,
          parentId: parent.id,
          childIds: children.map((c) => c.id).toList(),
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        await tasks.createTask(
          title: 'Do your homework',
          description: 'Complete all school assignments for tomorrow',
          pbuckValue: 30,
          parentId: parent.id,
          childIds: children.map((c) => c.id).toList(),
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        // Create test rewards
        await rewards.createReward(
          title: 'Extra TV time',
          description: '30 minutes of additional TV time',
          pbuckCost: 100,
          parentId: parent.id,
        );

        await rewards.createReward(
          title: 'Ice cream',
          description: 'One ice cream of your choice',
          pbuckCost: 50,
          parentId: parent.id,
        );
      }
    }
  }
  await storage.clearCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<AuthService>.value(value: auth),
        Provider<TaskService>.value(value: tasks),
        Provider<RewardService>.value(value: rewards),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBucks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/parent_dashboard': (context) => const ParentDashboard(),
        '/manage_children': (context) => const ManageChildrenScreen(),
        '/manage_tasks': (context) => const ManageTasksScreen(),
        '/manage_rewards': (context) => const ManageRewardsScreen(),
        '/child_dashboard': (context) => const ChildDashboard(),
      },
    );
  }
}
