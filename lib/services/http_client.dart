// lib/services/http_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'environment_service.dart';

class HttpClient {
  /// Normalisasi URL: pastikan tidak ada double slash
  static String _buildUrl(String endpoint) {
    final baseUrl = EnvironmentService.apiUrl;
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$cleanBaseUrl/$cleanEndpoint';
  }

  static Future<dynamic> get(String endpoint) async {
    final url = _buildUrl(endpoint);
    print('🔍 GET: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    _throwIfNotOk(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> post(String endpoint, dynamic data) async {
    final url = _buildUrl(endpoint);
    print('📤 POST: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _throwIfNotOk(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> put(String endpoint, dynamic data) async {
    final url = _buildUrl(endpoint);
    print('🔄 PUT: $url');
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _throwIfNotOk(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> delete(String endpoint) async {
    final url = _buildUrl(endpoint);
    print('🗑️ DELETE: $url');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    _throwIfNotOk(response);
    final body = response.body;
    return body.isEmpty ? {'message': 'Deleted'} : jsonDecode(body);
  }

  static void _throwIfNotOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}