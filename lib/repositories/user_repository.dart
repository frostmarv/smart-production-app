// lib/repositories/user_repository.dart
import '../services/http_client.dart';

class UserRepository {
  /// Ambil semua user
  static Future<dynamic> getAllUsers() async {
    try {
      final data = await HttpClient.get('/api/users');
      return data; // ✅ Langsung kembalikan, seperti JS
    } catch (error) {
      print('Gagal mengambil daftar user: $error');
      rethrow; // ✅ Lempar ulang error asli
    }
  }

  /// Ambil detail user berdasarkan ID
  static Future<dynamic> getUserById(String id) async {
    try {
      final data = await HttpClient.get('/api/users/$id');
      return data; // ✅
    } catch (error) {
      print('Gagal mengambil detail user: $error');
      rethrow;
    }
  }

  /// Buat user baru
  static Future<dynamic> createUser(Map<String, dynamic> userData) async {
    try {
      final data = await HttpClient.post('/api/users', userData);
      return data; // ✅
    } catch (error) {
      print('Gagal membuat user: $error');
      rethrow;
    }
  }

  /// Update user berdasarkan ID
  static Future<dynamic> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      final data = await HttpClient.put('/api/users/$id', userData);
      return data; // ✅
    } catch (error) {
      print('Gagal mengupdate user: $error');
      rethrow;
    }
  }

  /// Reset password user berdasarkan ID
  static Future<dynamic> resetUserPassword(String userId, String newPassword) async {
    try {
      final data = await HttpClient.put(
        '/api/users/$userId/reset-password',
        {'newPassword': newPassword},
      );
      return data; // ✅
    } catch (error) {
      print('Gagal reset password: $error');
      rethrow;
    }
  }

  /// Hapus user berdasarkan ID
  static Future<dynamic> deleteUser(String id) async {
    try {
      final data = await HttpClient.delete('/api/users/$id');
      return data; // ✅ Sesuai JS: kembalikan respons (bisa null, bisa objek)
    } catch (error) {
      print('Gagal menghapus user: $error');
      rethrow;
    }
  }

  /// Ambil profile user sendiri
  static Future<dynamic> getProfile() async {
    try {
      final data = await HttpClient.get('/api/users/profile');
      return data; // ✅
    } catch (error) {
      print('Gagal mengambil profile: $error');
      rethrow;
    }
  }

  /// Update profile user sendiri
  static Future<dynamic> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final data = await HttpClient.put('/api/users/profile', profileData);
      return data; // ✅
    } catch (error) {
      print('Gagal mengupdate profile: $error');
      rethrow;
    }
  }
}