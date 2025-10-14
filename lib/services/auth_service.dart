// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'http_client.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';

  // Login dan simpan token
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await HttpClient.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.containsKey('access_token') && response.containsKey('refresh_token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, response['access_token']);
        await prefs.setString(_refreshTokenKey, response['refresh_token']);
        await prefs.setString(_userKey, jsonEncode(response['user']));

        return response;
      }
    } catch (e) {
      print('❌ Login gagal: $e');
    }
    return null;
  }

  // Logout: hapus semua token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  // Cek apakah user sudah login dan token belum expired
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // Ambil access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Ambil refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Ambil data user
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  // Refresh access token menggunakan refresh token
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      await logout();
      return false;
    }

    try {
      final response = await HttpClient.post('/api/auth/refresh', {}, // kirim refresh token di header
        headers: {'Authorization': 'Bearer $refreshToken'},
      );

      if (response.containsKey('access_token') && response.containsKey('refresh_token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, response['access_token']);
        await prefs.setString(_refreshTokenKey, response['refresh_token']);
        return true;
      }
    } catch (e) {
      print('❌ Refresh token gagal: $e');
      await logout();
    }

    return false;
  }

  // Cek dan refresh token jika perlu
  static Future<String?> getValidAccessToken() async {
    if (!await isAuthenticated()) {
      return null;
    }

    String? token = await getAccessToken();

    // Jika token expired, coba refresh
    if (token != null && JwtDecoder.isExpired(token)) {
      bool success = await refreshAccessToken();
      if (success) {
        token = await getAccessToken(); // ambil token baru
      } else {
        return null; // refresh gagal
      }
    }

    return token;
  }
}