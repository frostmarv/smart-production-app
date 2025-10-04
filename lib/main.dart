// lib/main.dart
import 'package:flutter/material.dart';
// --- Import services ---
import 'services/environment_service.dart';
// --- Import screen utama ---
import 'screens/home_pages/home_screen.dart';

/// Fungsi utama aplikasi.
/// 
/// Aplikasi menggunakan backend API dengan konfigurasi environment
/// yang dapat diatur melalui file .env
void main() async {
  // Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi environment service dengan metode yang benar
  await EnvironmentService.init();
  
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
      title: 'Smart Production App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Sembunyikan banner debug
    );
  }
}
