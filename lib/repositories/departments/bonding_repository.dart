// lib/repositories/departments/bonding_repository.dart
import 'package:zinus_production/services/http_client.dart';

class BondingRepository {
  /// Submit form input bonding (khusus UI input)
  /// Endpoint: POST /api/bonding/summary/form-input
  static Future<Map<String, dynamic>> submitFormInput(Map<String, dynamic> formData) async {
    print('📤 Submitting bonding form: $formData');
    return await HttpClient.post('/api/bonding/summary/form-input', formData);
  }

  /// GET all bonding summaries
  /// Endpoint: GET /api/bonding/summary
  static Future<List<dynamic>> getAllSummaries() async {
    print('🔍 Fetching all bonding summaries');
    final response = await HttpClient.get('/api/bonding/summary');
    return response as List<dynamic>;
  }

  /// GET bonding summary by ID
  /// Endpoint: GET /api/bonding/summary/{id}
  static Future<Map<String, dynamic>> getSummaryById(String id) async {
    print('🔍 Fetching bonding summary by ID: $id');
    final response = await HttpClient.get('/api/bonding/summary/$id');
    return response as Map<String, dynamic>;
  }

  /// POST new summary (alternatif)
  /// Endpoint: POST /api/bonding/summary
  static Future<Map<String, dynamic>> createSummary(Map<String, dynamic> data) async {
    print('📤 Creating new bonding summary: $data');
    return await HttpClient.post('/api/bonding/summary', data);
  }

  /// PUT update summary
  /// Endpoint: PUT /api/bonding/summary/{id}
  static Future<Map<String, dynamic>> updateSummary(String id, Map<String, dynamic> data) async {
    print('🔄 Updating bonding summary $id: $data');
    return await HttpClient.put('/api/bonding/summary/$id', data);
  }

  /// DELETE summary
  /// Endpoint: DELETE /api/bonding/summary/{id}
  static Future<void> deleteSummary(String id) async {
    print('🗑️ Deleting bonding summary $id');
    await HttpClient.delete('/api/bonding/summary/$id');
  }
}