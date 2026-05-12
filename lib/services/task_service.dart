import 'dart:convert';
import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  static const String endpoint = '/tareas';

  static Future<List<AppTask>> getTasks({int? projectId}) async {
    String url = endpoint;
    if (projectId != null) {
      url += '?id_proyecto=$projectId';
    }
    final response = await ApiService.get(url);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) {
        try {
          return AppTask.fromJson(e);
        } catch (err) {
          print("Error parsing task: $err");
          return null;
        }
      }).whereType<AppTask>().toList();
    }
    throw Exception('Error al cargar tareas');
  }

  static Future<AppTask> createTask(AppTask task) async {
    final response = await ApiService.post(endpoint, task.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppTask.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear tarea');
  }

  static Future<AppTask> updateTask(int id, AppTask task) async {
    final response = await ApiService.put('$endpoint/$id', task.toJson());
    if (response.statusCode == 200) {
      return AppTask.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar tarea');
  }

  static Future<void> deleteTask(int id) async {
    final response = await ApiService.delete('/tareas/$id');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar tarea');
    }
  }

  static Future<void> assignUser(int taskId, int userId) async {
    final response = await ApiService.post('/tareas/$taskId/usuarios', {
      'id_usuarios': [userId]
    });
    if (response.statusCode != 201) {
      throw Exception('Error al asignar usuario');
    }
  }
}
