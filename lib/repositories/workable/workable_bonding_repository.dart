// lib/repositories/workable_bonding_repository.dart
import 'package:smart_production_app/services/http_client.dart';

/// Repository untuk mengakses data Workable Bonding dari backend.
/// Setara dengan `workable-bonding.js` di React.
class WorkableBondingRepository {
  /// Ambil data Workable Bonding (ringkasan)
  /// Endpoint: GET /api/workable-bonding
  static Future<List<dynamic>> getWorkableBonding() async {
    return await HttpClient.get('/api/workable-bonding');
  }

  /// Ambil data Detail Workable Bonding
  /// Endpoint: GET /api/workable-bonding/detail
  static Future<List<dynamic>> getWorkableBondingDetail() async {
    return await HttpClient.get('/api/workable-bonding/detail');
  }
}