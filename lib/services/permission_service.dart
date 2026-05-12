import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/permission.dart';
import '../models/role.dart';
import '../models/module.dart';
import '../models/role_permission.dart';
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
  /// Admin: Obtener todos los roles
  static Future<List<Role>> getAllRoles() async {
    final res = await ApiService.get('/catalogos/roles');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((item) => Role.fromJson(item)).toList();
    }
    return [];
  }

  /// Admin: Obtener todos los módulos
  static Future<List<AppModule>> getAllModules() async {
    final res = await ApiService.get('/catalogos/modulos');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((item) => AppModule.fromJson(item)).toList();
    }
    return [];
  }

  /// Admin: Obtener permisos de un rol específico
  static Future<List<RolePermission>> getPermissionsByRole(int idRol) async {
    final res = await ApiService.get('/rol-permisos/$idRol');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((item) => RolePermission.fromJson(item)).toList();
    }
    return [];
  }

  /// Admin: Crear o actualizar un permiso
  static Future<bool> updateRolePermission(RolePermission rp) async {
    final res = await ApiService.put('/rol-permisos/', rp.toJson());
    return res.statusCode == 200;
  }
}
