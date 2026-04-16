import 'dart:convert';
import '../models/client.dart';
import 'api_service.dart';

class ClientService {
  static const String endpoint = '/clientes';

  static Future<List<Client>> getClients() async {
    final response = await ApiService.get(endpoint);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Client.fromJson(e)).toList();
    }
    throw Exception('Error al cargar clientes');
  }

  static Future<Client> getClient(int id) async {
    final response = await ApiService.get('$endpoint/$id');
    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al cargar datos del cliente');
  }

  static Future<Client> createClient(Client client) async {
    final response = await ApiService.post(endpoint, client.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Client.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear cliente');
  }

  static Future<Client> updateClient(int id, Client client) async {
    final response = await ApiService.put('$endpoint/$id', client.toJson());
    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar cliente');
  }

  static Future<void> deleteClient(int id) async {
    final response = await ApiService.delete('$endpoint/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar cliente');
    }
  }
}
