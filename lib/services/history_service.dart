import 'dart:convert';
import 'api_service.dart';
import '../models/history_entry.dart';

class HistoryService {
  static Future<List<HistoryEntry>> getEntityHistory(String entity, int id) async {
    final response = await ApiService.get('/historial/$entity/$id/');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HistoryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener el historial: ${response.body}');
    }
  }

  static Future<List<HistoryEntry>> getAllHistory({String? entity}) async {
    String endpoint = '/historial/';
    if (entity != null) {
      endpoint = '/historial/?entidad=$entity';
    }
    final response = await ApiService.get(endpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HistoryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener el historial general: ${response.body}');
    }
  }
}
