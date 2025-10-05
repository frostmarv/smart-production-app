// lib/screens/home_pages/more/more_home_page.dart
import 'package:flutter/material.dart';
import 'package:zinus_production/screens/home_pages/workable/bonding/workable_bonding_page.dart';

class MoreHomeScreen extends StatelessWidget {
  const MoreHomeScreen({super.key});

  static const List<Map<String, dynamic>> departments = [
    {
      'name': 'Packing Foam',
      'icon': Icons.inventory_2_rounded,
      'color': Colors.green,
      'route': null,
    },
    {
      'name': 'Packing Spring',
      'icon': Icons.safety_check_rounded,
      'color': Colors.orange,
      'route': null,
    },
    {
      'name': 'Bonding',
      'icon': Icons.factory_rounded,
      'color': Colors.blue,
      'route': WorkableBondingPage.new,
    },
    {
      'name': 'Cutting',
      'icon': Icons.content_cut_rounded,
      'color': Colors.purple,
      'route': null,
    },
    {
      'name': 'Sewing',
      'icon': Icons.local_laundry_service_rounded, // ✅ Lebih relevan (jika pakai Flutter >=3.7)
      'color': Colors.pink,
      'route': null,
    },
    {
      'name': 'Quilting',
      'icon': Icons.layers_rounded, // ✅ Melambangkan lapisan kain
      'color': Colors.teal,
      'route': null,
    },
    {
      'name': 'Spring Core',
      'icon': Icons.circle_rounded, // Tetap bisa dipakai, atau ganti:
      // 'icon': Icons.settings_suggest_rounded, // alternatif
      'color': Colors.red,
      'route': null,
    },
    {
      'name': 'C/D-Box',
      'icon': Icons.inventory_2_rounded,
      'color': Colors.indigo,
      'route': null,
    },
    {
      'name': 'Finish Good',
      'icon': Icons.check_circle_rounded,
      'color': Colors.cyan,
      'route': null,
    },
    {
      'name': 'Quality Control',
      'icon': Icons.checklist_rounded,
      'color': Colors.lime,
      'route': null,
    },
    {
      'name': 'Maintenance',
      'icon': Icons.build_rounded,
      'color': Colors.brown,
      'route': null,
    },
    {
      'name': 'Logistics',
      'icon': Icons.local_shipping_rounded,
      'color': Colors.deepOrange,
      'route': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Departments",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: departments.length,
          itemBuilder: (context, index) {
            final dept = departments[index];
            return _buildDepartmentItem(
              context,
              name: dept['name'] as String,
              icon: dept['icon'] as IconData,
              color: dept['color'] as Color,
              route: dept['route'] as Widget Function()?,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDepartmentItem(
    BuildContext context, {
    required String name,
    required IconData icon,
    required Color color,
    Widget Function()? route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name - Halaman belum tersedia')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}