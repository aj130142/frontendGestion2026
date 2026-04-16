import '../../models/user.dart';
import 'api_service.dart';
import 'dart:convert';

class UserService {
  static Future<List<User>> getUsers() async {
    final response = await ApiService.get('/usuarios/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Error al obtener usuarios');
  }

  static Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await ApiService.post('/usuarios/', userData);
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear usuario');
  }

  static Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await ApiService.put('/usuarios/$id', userData);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar usuario');
  }

  static Future<void> deleteUser(int id) async {
    final response = await ApiService.delete('/usuarios/$id');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario');
    }
  }
}
