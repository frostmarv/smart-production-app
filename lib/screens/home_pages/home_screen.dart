
// lib/screens/home_pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:zinus_production/widgets/app_bar.dart';
import 'package:zinus_production/widgets/bottom_nav_bar.dart';

// Import semua halaman dari file terpisah
import '../stock/stock_screen.dart';
import '../report/report_screen.dart';
import '../more/more_screen.dart';
import './home/home_page_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Definisikan halaman di sini untuk akses yang mudah. Key diperlukan untuk stabilitas.
  final List<Widget> _pages = [
    const HomePageContent(key: ValueKey('home_page')),
    const StockScreen(key: ValueKey('stock_screen')),
    const ReportScreen(key: ValueKey('report_screen')),
    const MoreScreen(key: ValueKey('more_screen')),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(),
      // SOLUSI DEFINITIF: Menggunakan Stack + Offstage
      // Ini adalah pengganti yang lebih eksplisit untuk IndexedStack dan seringkali
      // lebih andal dalam kasus-kasus edge yang kompleks di mana IndexedStack gagal.
      body: Stack(
        children: List.generate(_pages.length, (index) {
          return Offstage(
            offstage: _currentIndex != index,
            // TickerMode memastikan animasi di halaman yang tidak terlihat dijeda.
            child: TickerMode(
              enabled: _currentIndex == index,
              child: _pages[index],
            ),
          );
        }),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
