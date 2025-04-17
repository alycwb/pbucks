import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final _uuid = const Uuid();
  final StorageService _storageService;

  AuthService(this._storageService);

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? parentId,
  }) async {
    try {
      print('Tentando registrar usuário: $email');
      
      // Gerar um novo ID para o usuário
      final userId = _uuid.v4();

      // Depois, criar o registro na tabela users
      final userData = {
        'id': userId,
        'name': name,
        'email': email,
        'password_hash': password,
        'role': role.name,
        if (parentId != null) 'parent_id': parentId,
      };

      print('Tentando inserir usuário no banco: $userData');
      final response = await Supabase.instance.client.from('users').insert(userData).select().single();
      print('Usuário inserido com sucesso');

      // Retornar o usuário criado
      return User(
        id: userId,
        name: name,
        email: email,
        password: password,
        role: role,
        parentId: parentId,
      );
    } catch (e) {
      print('Erro detalhado: $e');
      if (e is PostgrestException) {
        print('PostgrestException: ${e.message}');
        if (e.code == '23505') { // unique violation
          throw Exception('Este email já está cadastrado');
        } else if (e.code == '23502') { // not-null constraint
          throw Exception('Erro ao salvar dados do usuário');
        }
        throw Exception(e.message ?? 'Erro desconhecido no banco de dados');
      }
      throw Exception('Erro inesperado: ${e.toString()}');
    }
  }

  Future<User?> login(
    String email,
    String password,
    UserRole role,
  ) async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('email', email)
        .eq('password_hash', password)
        .eq('role', role.name)
        .maybeSingle();
    if (response == null) {
      return null;
    }
    return User(
      id: response['id'],
      name: response['name'],
      email: response['email'],
      password: response['password_hash'],
      role: role,
      parentId: response['parent_id'],
      pbuckBalance: response['pbuck_balance'] ?? 0,
    );
  }

  Future<void> logout() async {}
  Future<User?> getCurrentUser() async => null;
  Future<bool> isEmailAvailable(String email) async => true;
  Future<User> createParentAccount(String name, String email, String password) async => throw UnimplementedError();
  Future<User> createChildAccount(String name, String email, String parentId, String password) async => throw UnimplementedError();

  Future<List<User>> getAllParents() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('role', UserRole.parent.name);

      return (response as List<dynamic>)
          .map((data) => User(
                id: data['id'],
                name: data['name'],
                email: data['email'],
                password: data['password_hash'],
                role: UserRole.parent,
                parentId: null,
              ))
          .toList();
    } catch (e) {
      print('Erro ao buscar parents: $e');
      return [];
    }
  }
} 