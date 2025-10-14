// lib/repositories/workable_bonding_repository.dart
import 'package:zinus_production/services/http_client.dart';

/// Repository untuk mengakses data Workable Bonding dari backend.
/// Setara dengan `workable-bonding.js` di React.
class WorkableBondingRepository {
  /// Ambil data Workable Bonding (ringkasan)
  /// Endpoint: GET /api/workable-bonding
  static Future<List<dynamic>> getWorkableBonding() async {
    return await HttpClient.get('/api/workable-bonding');
  }

  /// Ambil data Detail Workable Bonding (per layer)
  /// Endpoint: GET /api/workable-bonding/detail
  static Future<List<dynamic>> getWorkableBondingDetail() async {
    return await HttpClient.get('/api/workable-bonding/detail');
  }

  /// Ambil data NG dan Replacement per layer
  /// Endpoint: GET /api/workable-bonding/reject
  static Future<List<dynamic>> getWorkableBondingReject() async {
    return await HttpClient.get('/api/workable-bonding/reject');
  }
}