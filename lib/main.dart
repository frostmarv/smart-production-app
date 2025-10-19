// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebase core
import 'firebase_options.dart'; // ✅ Generated via FlutterFire CLI

// --- Services ---
import 'services/environment_service.dart';
import 'services/permission_service.dart';

// --- Screens ---
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_pages/home/home_page_content.dart';
import 'screens/home_pages/home/notification_page.dart';
import 'screens/more/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Solusi Final: Coba inisialisasi, jika gagal karena sudah ada, abaikan
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully.');
  } catch (e) {
    print('Firebase initialization error or already initialized: $e');
  }

  // ✅ Inisialisasi service tambahan
  await EnvironmentService.init();
  await PermissionService.requestInitialPermissions();

  // ✅ Jalankan aplikasi
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

      // 🔥 Rute awal
      initialRoute: '/splash',

      // 🔗 Daftar route utama
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePageContent(),
        '/notifications': (context) => NotificationPage(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}