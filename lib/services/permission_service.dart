// lib/services/permission_service.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk mengelola permission aplikasi
class PermissionService {
  /// Request storage permission untuk menyimpan screenshot
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) menggunakan permission berbeda
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // Android 12 ke bawah
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // Platform lain tidak perlu permission
  }

  /// Check apakah storage permission sudah diberikan
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return await Permission.photos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return true;
  }

  /// Request permission saat pertama kali buka app
  static Future<void> requestInitialPermissions() async {
    // Request storage permission untuk screenshot feature
    await requestStoragePermission();
  }

  /// Check Android version
  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      // Android 13 = API level 33
      return true; // Simplified, bisa ditambahkan device_info_plus untuk check exact version
    }
    return false;
  }

  /// Show permission settings jika user menolak permission
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
