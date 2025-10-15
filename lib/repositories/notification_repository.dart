// lib/repositories/notification_repository.dart
import 'dart:convert';
import 'package:zinus_production/services/http_client.dart';
import 'package:zinus_production/models/notification.dart';

class NotificationRepository {
  // ✅ Gunakan HttpClient secara static

  Future<List<NotificationModel>> getNotifications({Map<String, String>? params}) async {
    // Gunakan HttpClient.get secara static, dan kirim params sebagai query string
    final response = await HttpClient.get('/api/notification', params: params);

    if (response is Map && response.containsKey('data')) {
      final List<dynamic> notificationsList = response['data'];
      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Invalid response format or no data key');
    }
  }

  Future<NotificationModel> getNotificationById(String id) async {
    final response = await HttpClient.get('/api/notification/$id');
    
    if (response is Map && response.containsKey('data')) {
      return NotificationModel.fromJson(response['data']);
    } else {
      throw Exception('Invalid response format or no data key');
    }
  }

  Future<void> markAsRead(String id) async {
    await HttpClient.put('/api/notification/$id/read', null);
  }

  Future<void> markMultipleAsRead(List<String> ids) async {
    // ✅ Koreksi: hapus `data:` dan gunakan parameter posisi
    await HttpClient.put('/api/notification/read/multiple', {'ids': ids});
  }

  Future<void> markAllAsRead({String? recipientDepartment}) async {
    final params = recipientDepartment != null ? {'recipientDepartment': recipientDepartment} : null;
    // ✅ Data body = null, params sebagai query
    await HttpClient.put('/api/notification/read/all', null, params: params);
  }

  Future<int> getUnreadCount({String? recipientDepartment}) async {
    final params = recipientDepartment != null ? {'recipientDepartment': recipientDepartment} : null;
    final response = await HttpClient.get('/api/notification/unread-count', params: params);

    if (response is Map && response.containsKey('data') && response['data'] is Map) {
      return (response['data'] as Map)['count'] ?? 0;
    } else {
      throw Exception('Invalid unread count response or no count key');
    }
  }
}