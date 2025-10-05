
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
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePageContent(key: ValueKey('home_page')),
          StockScreen(key: ValueKey('stock_screen')),
          ReportScreen(key: ValueKey('report_screen')),
          MoreScreen(key: ValueKey('more_screen')),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
