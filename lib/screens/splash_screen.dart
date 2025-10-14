// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/auth_service.dart'; // 👈 Tambahkan ini!
import 'login_screen.dart';           // 👈 Pastikan file ini ada
import 'home_pages/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setFullscreen();
    _initializeVideo();
  }

  void _setFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/zinus_splash.mp4');

    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });

      await _controller.play();

      // 🔥 Ganti: Jangan langsung ke Home! Tunggu video selesai, lalu cek auth
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _checkAuthAndNavigate(); // 👈 Ini yang baru!
        }
      });
    } catch (e) {
      // Jika video gagal, cek auth setelah 2 detik
      Future.delayed(const Duration(seconds: 2), _checkAuthAndNavigate);
    }
  }

  // 🔑 Fungsi baru: cek login, lalu tentukan tujuan
  Future<void> _checkAuthAndNavigate() async {
    // Restore UI dulu biar nggak stuck immersive
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Coba dapatkan access token yang valid (auto-refresh jika perlu)
    final accessToken = await AuthService.getValidAccessToken();

    if (!mounted) return;

    if (accessToken != null) {
      // Sudah login → ke Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Belum login → ke Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}