import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.parent;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _setCredentialsForRole(UserRole.parent);
  }

  void _setCredentialsForRole(UserRole role) {
    if (role == UserRole.parent) {
      _emailController.text = 'test@example.com';
      _passwordController.text = 'password123';
    } else {
      _emailController.text = 'joao@test.com';
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      print('Attempting login with:');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Role: $_selectedRole');
      
      final user = await authService.login(
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );

      if (user != null) {
        print('Login successful for user: ${user.email}');
        if (context.mounted) {
          if (user.role == UserRole.parent) {
            final storageService = Provider.of<StorageService>(context, listen: false);
            await storageService.setCurrentUser(user);
            await storageService.addTestChildren(user.id);
            Navigator.pushReplacementNamed(context, '/parent_dashboard');
          } else {
            final storageService = Provider.of<StorageService>(context, listen: false);
            await storageService.setCurrentUser(user);
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/child_dashboard');
            }
          }
        }
      } else {
        print('Login failed - invalid credentials');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: Column(
                          children: [
                            SegmentedButton<UserRole>(
                              segments: const [
                                ButtonSegment<UserRole>(
                                  value: UserRole.parent,
                                  label: Text('Parent'),
                                  icon: Icon(Icons.person),
                                ),
                                ButtonSegment<UserRole>(
                                  value: UserRole.child,
                                  label: Text('Child'),
                                  icon: Icon(Icons.child_care),
                                ),
                              ],
                              selected: {_selectedRole},
                              onSelectionChanged: (Set<UserRole> newSelection) {
                                setState(() {
                                  _selectedRole = newSelection.first;
                                  _setCredentialsForRole(newSelection.first);
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 300,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 