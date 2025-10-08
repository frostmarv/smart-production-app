// lib/main.dart
import 'package:flutter/material.dart';
// --- Import services ---
import 'services/environment_service.dart';
import 'services/permission_service.dart';
// --- Import screen utama ---
import 'screens/splash_screen.dart';

/// Fungsi utama aplikasi.
/// 
/// Aplikasi menggunakan backend API dengan konfigurasi environment
/// yang dapat diatur melalui file .env
void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi environment service dengan metode yang benar
  await EnvironmentService.init();
  
  // Request permissions saat app pertama kali dibuka
  // Popup permission akan muncul di sini
  await PermissionService.requestInitialPermissions();
  
  // --- Jalankan aplikasi ---
  runApp(const MyApp());
}

/// Widget root aplikasi.
class MyApp extends StatelessWidget {
  /// Membuat instance [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zinus Production',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
