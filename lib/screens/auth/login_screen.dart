import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../models/user.dart';
import '../../services/auth_service.dart';
import 'dart:html' as html;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.parent;
  UserRole _registerRole = UserRole.parent;
  List<User> _parents = [];
  User? _selectedParent;
  String? _parentId;

  @override
  void initState() {
    super.initState();
    logToLocalStorage('App iniciado');
    _setCredentialsForRole(UserRole.parent);
    _loadParents();
  }

  Future<void> _loadParents() async {
    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final parents = await authService.getAllParents();
    setState(() {
      _parents = parents;
      if (parents.isNotEmpty) {
        _selectedParent = parents.first;
        _parentId = parents.first.id;
      }
    });
  }

  void _setCredentialsForRole(UserRole role) {
    setState(() {
      if (role == UserRole.parent) {
        _emailController.text = 'alysson.isidro@gmail.com';
        _passwordController.text = '123456';
      } else {
        _emailController.text = 'joao@test.com';
        _passwordController.text = '123456';
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        final user = await authService.login(
          _emailController.text,
          _passwordController.text,
          _selectedRole,
        );

        if (user != null) {
          if (context.mounted) {
            if (user.role == UserRole.parent) {
              Navigator.pushReplacementNamed(context, '/parent_dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/child_dashboard');
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid credentials')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showRegisterDialog() {
    final _registerFormKey = GlobalKey<FormState>();
    final _registerNameController = TextEditingController();
    final _registerEmailController = TextEditingController();
    final _registerPasswordController = TextEditingController();
    UserRole _registerRole = UserRole.parent;
    String? _parentId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register'),
          content: SizedBox(
            width: 450,
            height: 280,
            child: Form(
              key: _registerFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _registerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _registerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _registerPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_registerFormKey.currentState!.validate()) {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  try {
                    logToLocalStorage('Iniciando cadastro para: ${_registerEmailController.text}');
                    await authService.register(
                      name: _registerNameController.text,
                      email: _registerEmailController.text,
                      password: _registerPasswordController.text,
                      role: UserRole.parent,
                    );
                    logToLocalStorage('Cadastro realizado: ${_registerEmailController.text} (parent)');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration successful!')),
                      );
                    }
                  } catch (e) {
                    logToLocalStorage('Erro no cadastro: ${e.toString()}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registration failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void _showLogDialog() {
    final log = getLocalStorageLog();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log do sistema'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: SelectableText(log.isEmpty ? 'Nenhum log.' : log),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              html.window.navigator.clipboard?.writeText(log);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log copiado para a área de transferência!')),
              );
            },
            child: const Text('Copiar log'),
          ),
        ],
      ),
    );
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
                                  _setCredentialsForRole(_selectedRole);
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                                    child: const Text('Login'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _showRegisterDialog,
                              child: const Text('Create Account'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _showLogDialog,
                              child: const Text('Ver log do sistema'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmação'),
                                    content: const Text('Tem certeza que deseja limpar TODOS os usuários da base?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Confirmar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    await Supabase.instance.client.from('users').delete().gt('created_at', '1900-01-01');
                                    logToLocalStorage('Base de usuários limpa com sucesso!');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Base de usuários limpa com sucesso!')),
                                      );
                                    }
                                  } catch (e) {
                                    print('Erro ao limpar base: ' + e.toString());
                                    logToLocalStorage('Erro ao limpar base: ${e.toString()}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao limpar base: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Limpar base de usuários'),
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

// Função para salvar logs em localStorage
void logToLocalStorage(String message) {
  final now = DateTime.now();
  final formattedDate = '[${now.toIso8601String()}]';
  final log = '$formattedDate $message';
  final currentLogs = html.window.localStorage['app_logs'] ?? '';
  html.window.localStorage['app_logs'] = '$currentLogs\n$log';
}

// Função para recuperar logs do localStorage
String getLocalStorageLog() {
  return html.window.localStorage['app_logs'] ?? '';
} 