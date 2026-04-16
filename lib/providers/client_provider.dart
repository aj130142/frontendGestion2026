import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;

  Future<void> fetchClients() async {
    _isLoading = true;
    notifyListeners();
    try {
      _clients = await ClientService.getClients();
    } catch (e) {
      debugPrint("Error loading clients: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createClient(Client client) async {
    try {
      final newClient = await ClientService.createClient(client);
      _clients.add(newClient);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error creating client: $e");
      return false;
    }
  }

  Future<bool> updateClient(int id, Client client) async {
    try {
      final updatedClient = await ClientService.updateClient(id, client);
      final index = _clients.indexWhere((c) => c.id == id);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating client: $e");
      return false;
    }
  }

  Future<bool> deleteClient(int id) async {
    try {
      await ClientService.deleteClient(id);
      _clients.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting client: $e");
      return false;
    }
  }
}
