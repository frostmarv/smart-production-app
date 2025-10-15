// lib/screens/home_pages/home/notification_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // untuk format tanggal

import 'package:zinus_production/repositories/notification_repository.dart';
import 'package:zinus_production/models/notification.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationRepository _notificationRepository;
  List<NotificationModel> notifications = [];
  bool loading = true;
  bool error = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _notificationRepository = NotificationRepository(); // Inisialisasi repository
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      loading = true;
      error = false;
    });

    try {
      final data = await _notificationRepository.getNotifications();
      setState(() {
        notifications = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = true;
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _notificationRepository.markAsRead(id);
      setState(() {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(readStatus: true);
        }
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai sebagai dibaca')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? _buildLoading()
          : error
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat notifikasi...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center( // ✅ Hapus const
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16), // ✅ Hapus const
          Text(
            'Gagal memuat notifikasi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8), // ✅ Hapus const
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), // ✅ Ini boleh karena bukan const
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16), // ✅ Hapus const
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (notifications.isEmpty) {
      return Center( // ✅ Hapus const
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey, // ✅ Boleh karena warna dasar
            ),
            const SizedBox(height: 16), // ✅ Hapus const
            const Text(
              'Belum ada notifikasi',
              style: TextStyle(fontSize: 16, color: Colors.grey), // ✅ Boleh karena warna dasar
            ),
            const SizedBox(height: 8), // ✅ Hapus const
            Text( // ✅ Hapus const karena warna index
              'Notifikasi akan muncul di sini',
              style: const TextStyle(color: Colors.grey).copyWith( // ✅ Ganti Colors.grey[500] jadi .copyWith(color: ...)
                color: Colors.grey[500], // ✅ Sekarang bisa karena .copyWith bukan const
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.readStatus ? Colors.grey.shade200 : Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!notification.readStatus) {
            _markAsRead(notification.id);
          }
          // Navigate ke link
          if (notification.link != null && notification.link!.isNotEmpty) {
            Navigator.pushNamed(context, notification.link!);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: notification.readStatus ? Colors.grey : Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.readStatus ? FontWeight.normal : FontWeight.w600,
                              fontSize: 16,
                              color: notification.readStatus ? Colors.grey[700] : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('HH:mm').format(notification.timestamp),
                          style: const TextStyle( // ✅ Ganti jadi const karena tidak pakai []
                            fontSize: 12,
                            color: Colors.grey, // ✅ Pakai warna dasar
                          ).copyWith( // ✅ Tambah .copyWith untuk warna index
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.readStatus ? Colors.grey[600] : Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeChip(notification.type),
                        const SizedBox(width: 8),
                        if (notification.relatedEntityType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification.relatedEntityType!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        // 🔥 Tambahkan info departemen (opsional)
                        const SizedBox(width: 8),
                        if (notification.recipientDepartments.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Ke: ${notification.recipientDepartments.join(', ')}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    IconData icon;

    switch (type.toUpperCase()) {
      case 'INFO':
        color = Colors.blue.shade100;
        icon = Icons.info_outline;
        break;
      case 'WARNING':
        color = Colors.orange.shade100;
        icon = Icons.warning_amber_outlined;
        break;
      case 'ERROR':
        color = Colors.red.shade100;
        icon = Icons.error_outline;
        break;
      case 'SUCCESS':
        color = Colors.green.shade100;
        icon = Icons.check_circle_outline;
        break;
      default:
        color = Colors.grey.shade100;
        icon = Icons.notifications_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.computeLuminance() < 0.5 ? Colors.white : Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.computeLuminance() < 0.5 ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}