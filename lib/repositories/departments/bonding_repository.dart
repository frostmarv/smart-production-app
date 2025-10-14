// lib/repositories/departments/bonding_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:zinus_production/services/http_client.dart';
// ✅ Import EnvironmentService
import 'package:zinus_production/services/environment_service.dart';

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

  /// 📤 UPLOAD IMAGES for NG/Reject (multipart/form-data)
  /// Endpoint: POST /api/bonding/reject/{id}/upload-images
  /// - Only for Reject (NG)
  /// - Max 10 images
  /// - Allowed: JPG, JPEG, PNG, GIF
  /// - Preserves original filename for ISO documentation
  static Future<Map<String, dynamic>> uploadRejectImages(
    String rejectId,
    List<File> images,
  ) async {
    // Validasi jumlah file
    if (images.isEmpty) {
      throw Exception('Tidak ada gambar yang dipilih');
    }
    if (images.length > 10) {
      throw Exception('Maksimal 10 gambar diperbolehkan');
    }

    print('📤 Uploading ${images.length} images for bonding reject: $rejectId');

    // ❌ Sebelum:
    // final uri = Uri.parse('${HttpClient.baseUrl}/api/bonding/reject/$rejectId/upload-images');

    // ✅ Sesudah: Gunakan EnvironmentService.apiUrl
    final uri = Uri.parse('${EnvironmentService.apiUrl}/api/bonding/reject/$rejectId/upload-images');
    
    final request = http.MultipartRequest('POST', uri);

    // Daftar ekstensi yang diizinkan
    final allowedExtensions = {'.jpg', '.jpeg', '.png', '.gif'};

    // Tambahkan setiap file
    for (var i = 0; i < images.length; i++) {
      final file = images[i];
      final filename = path.basename(file.path);
      final ext = path.extension(filename).toLowerCase();

      // Validasi ekstensi
      if (!allowedExtensions.contains(ext)) {
        throw Exception('File "$filename" tidak diizinkan. Hanya JPG, PNG, GIF.');
      }

      // Opsional: validasi ukuran (misal: max 10 MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File "$filename" terlalu besar (>10 MB)');
      }

      // Buat MultipartFile dengan nama file asli
      final multipartFile = await http.MultipartFile.fromPath(
        'images',
        file.path,
        filename: filename,
        contentType: MediaType('image', ext.replaceFirst('.', '')),
      );

      request.files.add(multipartFile);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload response status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Images uploaded successfully to Google Drive');
        return data;
      } else {
        final errorMsg = 'Upload gagal: ${response.statusCode} - ${response.body}';
        print('❌ $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('💥 Error during image upload: $e');
      rethrow;
    }
  }
}