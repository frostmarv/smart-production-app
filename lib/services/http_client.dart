// lib/services/http_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'environment_service.dart';
import 'auth_service.dart';

class HttpClient {
  static String _buildUrl(String endpoint, {Map<String, String>? params}) {
    final baseUrl = EnvironmentService.apiUrl;
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    String url = '$cleanBaseUrl/$cleanEndpoint';

    if (params != null && params.isNotEmpty) {
      // Filter nilai null/empty seperti di JS
      final filteredParams = <String, String>{};
      params.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          filteredParams[key] = value;
        }
      });
      if (filteredParams.isNotEmpty) {
        final queryString = Uri(queryParameters: filteredParams).query;
        url += '?$queryString';
      }
    }

    return url;
  }

  static Future<Map<String, String>> _getBaseHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json', // ✅ Tambahkan Accept header
    };
    final token = await AuthService.getValidAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ✅ Helper untuk parse JSON dengan aman (seperti parseJSON di JS)
  static dynamic _parseJson(String text) {
    if (text.trim() == '') {
      return null;
    }
    try {
      return jsonDecode(text);
    } catch (e) {
      print('❌ Gagal mengurai JSON: $text');
      throw Exception('Respons bukan JSON valid.');
    }
  }

  static Future<dynamic> _handleRequest(
    http.Request request,
    String method,
    String url,
    {Map<String, String>? customHeaders, dynamic bodyData}
  ) async {
    // Tambahkan header dasar
    final baseHeaders = await _getBaseHeaders();
    if (customHeaders != null) {
      baseHeaders.addAll(customHeaders);
    }
    request.headers.addAll(baseHeaders);

    if (bodyData != null) {
      request.body = jsonEncode(bodyData);
    }

    final response = await http.Response.fromStream(await request.send());
    print('📡 $method $url → ${response.statusCode}');

    // Handle 401: refresh token dan coba sekali lagi
    if (response.statusCode == 401) {
      final success = await AuthService.refreshAccessToken();
      if (success) {
        // Buat ulang request dengan token baru
        final newRequest = http.Request(request.method, Uri.parse(url));
        final newHeaders = await _getBaseHeaders();
        if (customHeaders != null) newHeaders.addAll(customHeaders);
        newRequest.headers.addAll(newHeaders);
        if (bodyData != null) {
          newRequest.body = jsonEncode(bodyData);
        }

        final retryResponse = await http.Response.fromStream(await newRequest.send());
        _throwIfNotOk(retryResponse);
        return _parseJson(retryResponse.body);
      } else {
        await AuthService.logout();
        throw Exception('Sesi habis. Silakan login kembali.');
      }
    }

    _throwIfNotOk(response);
    return _parseJson(response.body);
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final url = _buildUrl(endpoint, params: params);
    final request = http.Request('GET', Uri.parse(url));
    return _handleRequest(request, 'GET', url, customHeaders: headers);
  }

  static Future<dynamic> post(
    String endpoint,
    dynamic data, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final url = _buildUrl(endpoint, params: params);
    final request = http.Request('POST', Uri.parse(url));
    return _handleRequest(request, 'POST', url, customHeaders: headers, bodyData: data);
  }

  static Future<dynamic> put(
    String endpoint,
    dynamic data, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final url = _buildUrl(endpoint, params: params);
    final request = http.Request('PUT', Uri.parse(url));
    return _handleRequest(request, 'PUT', url, customHeaders: headers, bodyData: data);
  }

  static Future<void> delete(
    String endpoint, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final url = _buildUrl(endpoint, params: params);
    final request = http.Request('DELETE', Uri.parse(url));
    await _handleRequest(request, 'DELETE', url, customHeaders: headers);
    // Tidak perlu return body (seperti JS)
  }

  static void _throwIfNotOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';

      try {
        final body = _parseJson(response.body);
        if (body is Map) {
          errorMessage = body['message']?.toString() ??
                        body['error']?.toString() ??
                        errorMessage;
        }
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          errorMessage = '${response.statusCode}: ${response.body}';
        }
      }

      print('❌ HTTP Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }
}