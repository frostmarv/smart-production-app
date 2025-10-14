// lib/screens/report/report_screen.dart
import 'package:flutter/material.dart';

// Import halaman departemen yang akan diaktifkan
import 'package:zinus_production/screens/departments/bonding/bonding_home_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Tentukan halaman mana yang aktif dan mana yang "Coming Soon"
  static const List<Map<String, dynamic>> _departments = [
    {'name': 'Packing Foam', 'icon': Icons.inventory_rounded, 'color': Color(0xFF10B981), 'screen': null},
    {'name': 'Packing Spring', 'icon': Icons.precision_manufacturing_rounded, 'color': Color(0xFF3B82F6), 'screen': null},
    // FIX: Mengaktifkan navigasi untuk Bonding
    {'name': 'Bonding', 'icon': Icons.build_rounded, 'color': Color(0xFFF59E0B), 'screen': BondingHomeScreen()},
    {'name': 'Cutting', 'icon': Icons.content_cut_rounded, 'color': Color(0xFFEF4444), 'screen': null},
    {'name': 'Spring Core', 'icon': Icons.settings_rounded, 'color': Color(0xFF06B6D4), 'screen': null},
    {'name': 'Sewing', 'icon': Icons.design_services_rounded, 'color': Color(0xFF8B5CF6), 'screen': null},
    {'name': 'Quilting', 'icon': Icons.texture_rounded, 'color': Color(0xFFEC4899), 'screen': null},
  ];

  void _navigateToDepartment(BuildContext context, String departmentName, Widget? screen) {
    if (screen != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOutQuint)),
              ),
              child: child,
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$departmentName akan segera tersedia"),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // KODE ASLI DARI _ReportPageContent (TIDAK ADA PERUBAHAN GAYA)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
                SizedBox(height: 16),
                Text(
                  "Department Reports",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Select a department to view detailed reports",
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Departments List
          Column(
            children: _departments.map((department) {
              final screen = department['screen'] as Widget?;
              final color = department['color'] as Color;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => _navigateToDepartment(context, department['name'] as String, screen),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(department['icon'] as IconData, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                department['name'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (screen != null ? const Color(0xFF10B981) : const Color(0xFF64748B)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  screen != null ? 'Active' : 'Coming Soon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: screen != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
