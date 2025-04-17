import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  await Supabase.initialize(
    url: 'https://zkofeaaggzedjjlallgs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inprb2ZlYWFnZ3plZGpqbGFsbGdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3NjIyNzIsImV4cCI6MjA2MDMzODI3Mn0.E9f0CRwnodO4jKNHYoEktRIafMYkVtOZ6VfMl9OGm9Y',
  );

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AuthService>.value(value: AuthService(storageService)),
        Provider<TaskService>.value(value: TaskService(storageService)),
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
