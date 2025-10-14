import 'dart:convert';
import '../http_client.dart';
import '../models/notification.dart';

class NotificationRepository {
  final HttpClient _httpClient;

  NotificationRepository() : _httpClient = HttpClient();

  Future<List<NotificationModel>> getNotifications({Map<String, String>? params}) async {
    final response = await _httpClient.get('/api/notification', params: params);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> notificationsList = data['data'];
      
      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  Future<NotificationModel> getNotificationById(String id) async {
    final response = await _httpClient.get('/api/notification/$id');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return NotificationModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to load notification: ${response.body}');
    }
  }

  Future<void> markAsRead(String id) async {
    final response = await _httpClient.put('/api/notification/$id/read');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }

  Future<void> markMultipleAsRead(List<String> ids) async {
    final response = await _httpClient.put(
      '/api/notification/read/multiple',
      data: {'ids': ids},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notifications as read: ${response.body}');
    }
  }

  Future<void> markAllAsRead({String? recipientRole}) async {
    final params = recipientRole != null ? {'recipientRole': recipientRole} : null;
    final response = await _httpClient.put('/api/notification/read/all', params: params);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read: ${response.body}');
    }
  }

  Future<int> getUnreadCount({String? recipientRole}) async {
    final params = recipientRole != null ? {'recipientRole': recipientRole} : null;
    final response = await _httpClient.get('/api/notification/unread-count', params: params);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['count'] ?? 0;
    } else {
      throw Exception('Failed to get unread count: ${response.body}');
    }
  }
}