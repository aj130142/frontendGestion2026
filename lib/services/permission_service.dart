import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/permission.dart';
import 'api_service.dart';

class PermissionService {
  /// Llama a GET /auth/me/permisos y retorna un mapa modulo → Permission.
  /// Ante cualquier error retorna un mapa vacío (sin acceso a nada).
  static Future<PermissionMap> fetchPermisos() async {
    try {
      final res = await ApiService.get('/auth/me/permisos');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data.map(
          (modulo, perms) => MapEntry(
            modulo,
            Permission.fromJson(perms as Map<String, dynamic>),
          ),
        );
      } else {
        debugPrint('PermissionService: status ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('PermissionService error: $e');
    }
    return {};
  }
}
