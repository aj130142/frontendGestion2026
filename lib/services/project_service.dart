import 'dart:convert';
import '../models/project.dart';
import 'api_service.dart';

class ProjectService {
  static const String endpoint = '/proyectos';

  static Future<List<Project>> getProjects() async {
    final response = await ApiService.get(endpoint);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    }
    throw Exception('Error al cargar proyectos');
  }

  static Future<List<Project>> getProjectsByClient(int clientId) async {
    final response = await ApiService.get('/clientes/$clientId/proyectos');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    }
    throw Exception('Error al cargar proyectos del cliente');
  }

  static Future<Project> createProject(Project project) async {
    final response = await ApiService.post(endpoint, project.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear proyecto');
  }

  static Future<Project> updateProject(int id, Project project) async {
    final response = await ApiService.put('$endpoint/$id', project.toJson());
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar proyecto');
  }

  static Future<void> deleteProject(int id) async {
    final response = await ApiService.delete('$endpoint/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar proyecto');
    }
  }
}
