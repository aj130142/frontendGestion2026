import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// (#8) Almacenamiento seguro de tokens.
///
/// En Flutter Web: el token se almacena SOLO en memoria (variable estática).
/// Esto significa que al cerrar la pestaña se pierde la sesión, pero un script
/// malicioso XSS NO puede leer el token de localStorage.
///
/// En móvil/desktop: se usa SharedPreferences ya que no hay riesgo de XSS
/// y el sistema operativo protege el almacenamiento de la app.
class ApiService {
  // Use dotenv for API URL if available, otherwise fallback
  static String get baseUrl {
    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    if (kIsWeb) return 'https://web-production-92d26.up.railway.app';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  // (#8) Token en memoria para Flutter Web — NO se persiste en localStorage
  static String? _inMemoryToken;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _buildUrl(String endpoint) {
    String base = baseUrl;
    // Eliminar slash final de base si existe
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    // Asegurar que el endpoint empiece con slash
    String path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final headers = await _getHeaders();
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> postForm(String endpoint, Map<String, String> body) async {
    final url = Uri.parse(_buildUrl(endpoint));
    // For FastAPI OAuth2PasswordRequestForm
    return await http.post(url, body: body);
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  /// (#8) Guardar token de forma segura según la plataforma.
  /// Web: solo en memoria. Móvil: SharedPreferences.
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      // Web: almacenar solo en memoria — se pierde al cerrar pestaña
      _inMemoryToken = token;
    } else {
      // Móvil/Desktop: persistir de forma segura
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    }
  }

  /// (#8) Eliminar token según la plataforma.
  static Future<void> removeToken() async {
    if (kIsWeb) {
      _inMemoryToken = null;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    }
  }

  /// (#8) Obtener token según la plataforma.
  static Future<String?> getToken() async {
    if (kIsWeb) {
      return _inMemoryToken;
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final headers = await _getHeaders();
    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final headers = await _getHeaders();
    return await http.delete(url, headers: headers);
  }
}
