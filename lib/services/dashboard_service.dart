import 'dart:convert';
import '../models/dashboard_stats.dart';
import 'api_service.dart';

class DashboardService {
  static Future<List<StatusCount>> getProjectTaskStats(int projectId) async {
    final response = await ApiService.get('/proyectos/$projectId/tareas/stats');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => StatusCount.fromJson(json)).toList();
    }
    return [];
  }
}
