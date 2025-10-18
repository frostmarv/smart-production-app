// lib/main.dart
import 'package:flutter/material.dart';

// --- Services ---
import 'services/environment_service.dart';
import 'services/permission_service.dart';

// --- Screens ---
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart'; // 👈 pastikan file ini ada
import 'screens/home_pages/home/home_page_content.dart'; // Home utama setelah login
import 'screens/home_pages/home/notification_page.dart'; // 👈 halaman notifikasi
import 'screens/more/profile_screen.dart'; // 🔥 Tambahkan ini agar bisa navigasi ke profile
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentService.init();
  await PermissionService.requestInitialPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zinus Production',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 🔥 Gunakan initialRoute + routes
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePageContent(),
        '/notifications': (context) => NotificationPage(), // ✅ Sudah ada
        '/profile': (context) => const ProfileScreen(), // 🔥 Ditambahkan agar bisa pakai pushNamed
      },
    );
  }
}