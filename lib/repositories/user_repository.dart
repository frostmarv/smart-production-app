// lib/repositories/user_repository.dart
import '../services/http_client.dart';

class UserRepository {
  /// Ambil semua user
  static Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await HttpClient.get('/api/users');
      return List<dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil daftar user: $e');
    }
  }

  /// Ambil detail user berdasarkan ID
  static Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await HttpClient.get('/api/users/$id');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail user: $e');
    }
  }

  /// Buat user baru
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await HttpClient.post('/api/users', userData);
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal membuat user: $e');
    }
  }

  /// Update user berdasarkan ID
  static Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      final response = await HttpClient.put('/api/users/$id', userData);
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal mengupdate user: $e');
    }
  }

  /// Reset password user berdasarkan ID
  static Future<Map<String, dynamic>> resetUserPassword(String userId, String newPassword) async {
    try {
      final response = await HttpClient.put(
        '/api/users/$userId/reset-password',
        {'newPassword': newPassword},
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal reset password: $e');
    }
  }

  /// Hapus user berdasarkan ID
  static Future<void> deleteUser(String id) async {
    try {
      await HttpClient.delete('/api/users/$id');
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  /// Ambil profile user sendiri
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await HttpClient.get('/api/users/profile');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil profile: $e');
    }
  }

  /// Update profile user sendiri
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await HttpClient.put('/api/users/profile', profileData);
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Gagal mengupdate profile: $e');
    }
  }
}