// lib/services/http_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'environment_service.dart';
import 'auth_service.dart';

class HttpClient {
  /// Normalisasi URL: pastikan tidak ada double slash
  static String _buildUrl(String endpoint) {
    final baseUrl = EnvironmentService.apiUrl;
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$cleanBaseUrl/$cleanEndpoint';
  }

  /// Ambil headers dasar + access token (jika ada)
  static Future<Map<String, String>> _getBaseHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    final token = await AuthService.getValidAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> post(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    final url = _buildUrl(endpoint);
    print('📤 POST: $url');

    final baseHeaders = await _getBaseHeaders();
    if (headers != null) {
      baseHeaders.addAll(headers);
    }

    final response = await http.post(
      Uri.parse(url),
      headers: baseHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      final success = await AuthService.refreshAccessToken();
      if (success) {
        final newHeaders = await _getBaseHeaders();
        if (headers != null) newHeaders.addAll(headers);
        final retryResponse = await http.post(
          Uri.parse(url),
          headers: newHeaders,
          body: jsonEncode(data),
        );
        _throwIfNotOk(retryResponse);
        return jsonDecode(retryResponse.body);
      } else {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
    }

    _throwIfNotOk(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = _buildUrl(endpoint);
    print('🔍 GET: $url');
    
    final baseHeaders = await _getBaseHeaders();
    if (headers != null) baseHeaders.addAll(headers);
    
    final response = await http.get(Uri.parse(url), headers: baseHeaders);
    
    if (response.statusCode == 401) {
      final success = await AuthService.refreshAccessToken();
      if (success) {
        final newHeaders = await _getBaseHeaders();
        if (headers != null) newHeaders.addAll(headers);
        final retryResponse = await http.get(Uri.parse(url), headers: newHeaders);
        _throwIfNotOk(retryResponse);
        return jsonDecode(retryResponse.body);
      } else {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
    }
    
    _throwIfNotOk(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> put(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    final url = _buildUrl(endpoint);
    print('✏️ PUT: $url');

    final baseHeaders = await _getBaseHeaders();
    if (headers != null) {
      baseHeaders.addAll(headers);
    }

    final response = await http.put(
      Uri.parse(url),
      headers: baseHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 401) {
      final success = await AuthService.refreshAccessToken();
      if (success) {
        final newHeaders = await _getBaseHeaders();
        if (headers != null) newHeaders.addAll(headers);
        final retryResponse = await http.put(
          Uri.parse(url),
          headers: newHeaders,
          body: jsonEncode(data),
        );
        _throwIfNotOk(retryResponse);
        return jsonDecode(retryResponse.body);
      } else {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
    }

    _throwIfNotOk(response);
    return jsonDecode(response.body);
  }

  static Future<void> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = _buildUrl(endpoint);
    print('🗑️ DELETE: $url');

    final baseHeaders = await _getBaseHeaders();
    if (headers != null) {
      baseHeaders.addAll(headers);
    }

    final response = await http.delete(Uri.parse(url), headers: baseHeaders);

    if (response.statusCode == 401) {
      final success = await AuthService.refreshAccessToken();
      if (success) {
        final newHeaders = await _getBaseHeaders();
        if (headers != null) newHeaders.addAll(headers);
        final retryResponse = await http.delete(Uri.parse(url), headers: newHeaders);
        _throwIfNotOk(retryResponse);
        return; // No body to decode on success
      } else {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
    }

    _throwIfNotOk(response);
  }

  static void _throwIfNotOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
      
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          errorMessage = body['message'].toString();
        } else if (body is Map && body.containsKey('error')) {
          errorMessage = body['error'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = '${response.statusCode}: ${response.body}';
        }
      }
      
      print('❌ HTTP Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }
}