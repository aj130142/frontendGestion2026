import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await UserService.getUsers();
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(String name, String email, String password, int roleId) async {
    try {
      await UserService.createUser({
        'nombre': name,
        'correo': email,
        'password': password,
        'id_rol': roleId,
      });
      await fetchUsers();
      return true;
    } catch (e) {
      debugPrint("Error creating user: $e");
      return false;
    }
  }

  Future<bool> updateUser(int id, String name, String email, int roleId, bool active) async {
    try {
      await UserService.updateUser(id, {
        'nombre': name,
        'correo': email,
        'id_rol': roleId,
        'activo': active,
      });
      await fetchUsers();
      return true;
    } catch (e) {
      debugPrint("Error updating user: $e");
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await UserService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting user: $e");
      return false;
    }
  }
}
