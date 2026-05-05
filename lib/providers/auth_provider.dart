import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/permission.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  User? _currentUser;
  PermissionMap _permisos = {};

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get currentUser => _currentUser;

  // ─── Helpers de permiso por módulo ──────────────────────────────────────────

  /// Retorna el objeto Permission para el módulo dado.
  /// Si no existe la entrada, devuelve Permission.none (sin acceso).
  Permission permiso(String modulo) => _permisos[modulo] ?? Permission.none;

  bool puedeVer(String modulo)      => permiso(modulo).ver;
  bool puedeCrear(String modulo)    => permiso(modulo).crear;
  bool puedeEditar(String modulo)   => permiso(modulo).editar;
  bool puedeEliminar(String modulo) => permiso(modulo).eliminar;

  // ─── Carga de datos ─────────────────────────────────────────────────────────

  Future<bool> fetchProfile() async {
    final user = await AuthService.fetchProfile();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _fetchPermisos() async {
    _permisos = await PermissionService.fetchPermisos();
    notifyListeners();
  }

  Future<void> checkToken() async {
    final t = await ApiService.getToken();
    if (t != null) {
      _token = t;
      final profileSuccess = await fetchProfile();
      if (profileSuccess) {
        await _fetchPermisos();
        _isAuthenticated = true;
      } else {
        await logout();
      }
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final tokenData = await AuthService.login(username, password);
      if (tokenData != null) {
        _token = tokenData;
        await ApiService.saveToken(_token!);

        final profileSuccess = await fetchProfile();
        if (profileSuccess) {
          await _fetchPermisos();
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          debugPrint("Login: No se pudo cargar el perfil tras obtener token.");
          await logout();
        }
      }
    } catch (e) {
      debugPrint("AuthProvider Login Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// (#6b) Logout completo: revoca el token en el servidor y limpia el estado local.
  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService.post('/auth/logout/token', {'token': _token!});
      } catch (_) {
        debugPrint("No se pudo revocar el token en el servidor");
      }
    }

    await ApiService.removeToken();
    _isAuthenticated = false;
    _token = null;
    _currentUser = null;
    _permisos = {};
    notifyListeners();
  }
}
