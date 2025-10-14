// lib/repositories/master_data/master_data_repository.dart
import '../../services/http_client.dart';

class MasterDataRepository {
  // 1. Customers
  Future<List<dynamic>> getCustomers() async {
    try {
      final response = await HttpClient.get('/api/master-data/customers');
      return response as List<dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getCustomers): $e');
      rethrow;
    }
  }

  // 2. PO Numbers by Customer
  Future<List<dynamic>> getPoNumbers(String customerId) async {
    try {
      final response = await HttpClient.get(
        '/api/master-data/po-numbers?customerId=$customerId',
      );
      return response as List<dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getPoNumbers): $e');
      rethrow;
    }
  }

  // 3. Customer POs by PO Number
  Future<List<dynamic>> getCustomerPOs(String poNumber) async {
    try {
      final response = await HttpClient.get(
        '/api/master-data/customer-pos?poNumber=$poNumber',
      );
      return response as List<dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getCustomerPOs): $e');
      rethrow;
    }
  }

  // 4. SKUs by Customer PO
  Future<List<dynamic>> getSkus(String customerPo) async {
    try {
      final response = await HttpClient.get(
        '/api/master-data/skus?customerPo=$customerPo',
      );
      return response as List<dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getSkus): $e');
      rethrow;
    }
  }

  // 5. Qty Plans by Customer PO + SKU
  Future<List<dynamic>> getQtyPlans(String customerPo, String sku) async {
    try {
      final response = await HttpClient.get(
        '/api/master-data/qty-plans?customerPo=$customerPo&sku=$sku',
      );
      return response as List<dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getQtyPlans): $e');
      rethrow;
    }
  }

  // 6. Weeks by Customer PO + SKU
  Future<List<dynamic>> getWeeks(String customerPo, String sku) async {
    try {
      final response = await HttpClient.get(
        '/api/master-data/weeks?customerPo=$customerPo&sku=$sku',
      );
      return response as List<dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getWeeks): $e');
      rethrow;
    }
  }

  // 🔥 7. Untuk Cutting / halaman lain yang butuh sCode
  Future<Map<String, dynamic>> getRemainQuantity(
    String customerPo,
    String sku,
    String sCode,
  ) async {
    try {
      // ⚠️ Pastikan backend menyediakan endpoint ini!
      // Jika tidak, ganti ke /remain-quantity-cutting
      final response = await HttpClient.get(
        '/api/master-data/remain-quantity-cutting?customerPo=$customerPo&sku=$sku&sCode=$sCode',
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getRemainQuantity): $e');
      rethrow;
    }
  }

  // 🔥 8. BARU: Untuk Bonding (tanpa sCode)
  Future<Map<String, dynamic>> getRemainQuantityBonding(
    String customerPo,
    String sku,
  ) async {
    try {
      final response = await HttpClient.get(
        '/api/master-data/remain-quantity-bonding?customerPo=$customerPo&sku=$sku',
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ API Error (MasterDataRepository.getRemainQuantityBonding): $e');
      rethrow;
    }
  }
}