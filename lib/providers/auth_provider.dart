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

  Future<void> fetchProfile() async {
    final user = await AuthService.fetchProfile();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
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
      _isAuthenticated = true;
      await fetchProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await ApiService.removeToken();
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }
}
