// lib/repositories/departments/bonding_repository.dart
import 'package:zinus_production/services/http_client.dart';

class BondingRepository {
  // ==============================
  // 🔹 SUMMARY (GOOD / PRODUKSI)
  // ==============================

  /// Submit form input bonding (khusus UI input - GOOD)
  /// POST /api/bonding/summary/form-input
  static Future<Map<String, dynamic>> submitFormInput(Map<String, dynamic> formData) async {
    print('📤 Submitting bonding form to /api/bonding/summary/form-input');
    print('📦 Form data: $formData');
    try {
      final response = await HttpClient.post('/api/bonding/summary/form-input', formData);
      print('✅ Submit successful: $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ Submit failed: $e');
      rethrow;
    }
  }

  /// GET all bonding summaries
  static Future<List<dynamic>> getAllSummaries() async {
    print('🔍 Fetching all bonding summaries');
    final response = await HttpClient.get('/api/bonding/summary');
    return response as List<dynamic>;
  }

  /// GET bonding summary by ID
  static Future<Map<String, dynamic>> getSummaryById(String id) async {
    print('🔍 Fetching bonding summary by ID: $id');
    final response = await HttpClient.get('/api/bonding/summary/$id');
    return response as Map<String, dynamic>;
  }

  /// POST new summary (alternatif)
  static Future<Map<String, dynamic>> createSummary(Map<String, dynamic> data) async {
    print('📤 Creating new bonding summary: $data');
    return await HttpClient.post('/api/bonding/summary', data);
  }

  /// PUT update summary
  static Future<Map<String, dynamic>> updateSummary(String id, Map<String, dynamic> data) async {
    print('🔄 Updating bonding summary $id: $data');
    return await HttpClient.put('/api/bonding/summary/$id', data);
  }

  /// DELETE summary
  static Future<void> deleteSummary(String id) async {
    print('🗑️ Deleting bonding summary $id');
    await HttpClient.delete('/api/bonding/summary/$id');
  }

  // ==============================
  // 🔴 REJECT (NG / NOT GOOD)
  // ==============================

  /// POST - Input data NG (Reject)
  /// Endpoint: POST /api/bonding/reject/form-input
  static Future<Map<String, dynamic>> submitRejectFormInput(Map<String, dynamic> formData) async {
    print('📤 Submitting NG/reject form to /api/bonding/reject/form-input');
    print('📦 NG Form data: $formData');
    try {
      final response = await HttpClient.post('/api/bonding/reject/form-input', formData);
      print('✅ NG Submit successful: $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ NG Submit failed: $e');
      rethrow;
    }
  }

  /// GET - Ambil semua data NG
  /// Endpoint: GET /api/bonding/reject
  static Future<List<dynamic>> getAllRejects() async {
    print('🔍 Fetching all bonding rejects (NG)');
    final response = await HttpClient.get('/api/bonding/reject');
    return response as List<dynamic>;
  }

  /// GET - Ambil data NG berdasarkan ID
  /// Endpoint: GET /api/bonding/reject/{id}
  static Future<Map<String, dynamic>> getRejectById(String id) async {
    print('🔍 Fetching bonding reject by ID: $id');
    final response = await HttpClient.get('/api/bonding/reject/$id');
    return response as Map<String, dynamic>;
  }

  /// PUT - Update data NG
  /// Endpoint: PUT /api/bonding/reject/{id}
  static Future<Map<String, dynamic>> updateReject(String id, Map<String, dynamic> data) async {
    print('🔄 Updating bonding reject $id: $data');
    return await HttpClient.put('/api/bonding/reject/$id', data);
  }

  /// DELETE - Hapus data NG
  /// Endpoint: DELETE /api/bonding/reject/{id}
  static Future<void> deleteReject(String id) async {
    print('🗑️ Deleting bonding reject $id');
    await HttpClient.delete('/api/bonding/reject/$id');
  }
}