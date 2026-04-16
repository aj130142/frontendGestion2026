import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<User?> fetchProfile() async {
    try {
      final res = await ApiService.get('/auth/me');
      if (res.statusCode == 200) {
        return User.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error al descargar perfil: $e");
    }
    return null;
  }

  static Future<String?> login(String username, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'correo': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      }
    } catch (e) {
      debugPrint("Login error: $e");
    }
    return null;
  }
}
