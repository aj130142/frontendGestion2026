import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get canDelete => _currentUser?.roleId == 1; // Solo Admin borra

  Future<bool> fetchProfile() async {
    final user = await AuthService.fetchProfile();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> checkToken() async {
    final t = await ApiService.getToken();
    if (t != null) {
      _token = t;
      _isAuthenticated = true;
      await fetchProfile();
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final tokenData = await AuthService.login(username, password);
    if (tokenData != null) {
      _token = tokenData;
      await ApiService.saveToken(_token!);
      
      // Intentar cargar el perfil antes de confirmar la autenticación
      final profileSuccess = await fetchProfile();
      if (profileSuccess) {
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Si el perfil falla (ej. error de red/CORS), limpiar todo
        await logout();
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// (#6b) Logout completo: revoca el token en el servidor y limpia el estado local.
  Future<void> logout() async {
    // Revocar token en el backend antes de limpiar localmente
    if (_token != null) {
      try {
        await ApiService.post('/auth/logout/token', {'token': _token!});
      } catch (_) {
        // Si falla la revocación remota, continuar con el logout local
        debugPrint("No se pudo revocar el token en el servidor");
      }
    }

    await ApiService.removeToken();
    _isAuthenticated = false;
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}
