// lib/screens/home_pages/more/more_home_page.dart
import 'package:flutter/material.dart';
import 'package:zinus_production/screens/home_pages/workable/bonding/workable_bonding_page.dart';

class MoreHomeScreen extends StatelessWidget {
  const MoreHomeScreen({super.key});

  static const List<Map<String, dynamic>> departments = [
    {
      'name': 'Packing Foam',
      'icon': Icons.inventory_rounded, // ✅ konsisten dengan ReportScreen
      'color': Color(0xFF10B981),
      'route': null,
    },
    {
      'name': 'Packing Spring',
      'icon': Icons.precision_manufacturing_rounded, // ✅ lebih relevan
      'color': Color(0xFFF59E0B),
      'route': null,
    },
    {
      'name': 'Bonding',
      'icon': Icons.build_rounded, // ✅ konsisten dengan ReportScreen
      'color': Color(0xFFF59E0B),
      'route': WorkableBondingPage.new,
    },
    {
      'name': 'Cutting',
      'icon': Icons.content_cut_rounded,
      'color': Color(0xFFEF4444),
      'route': null,
    },
    {
      'name': 'Sewing',
      'icon': Icons.design_services_rounded, // ✅ lebih modern
      'color': Color(0xFF8B5CF6),
      'route': null,
    },
    {
      'name': 'Quilting',
      'icon': Icons.texture_rounded, // ✅ sesuai dengan ReportScreen
      'color': Color(0xFFEC4899),
      'route': null,
    },
    {
      'name': 'Spring Core',
      'icon': Icons.settings_rounded,
      'color': Color(0xFF06B6D4),
      'route': null,
    },
    {
      'name': 'C/D-Box',
      'icon': Icons.inventory_rounded,
      'color': Color(0xFF6B7280),
      'route': null,
    },
    {
      'name': 'Finish Good',
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF10B981),
      'route': null,
    },
    {
      'name': 'Quality Control',
      'icon': Icons.checklist_rounded,
      'color': Color(0xFF16A34A),
      'route': null,
    },
    {
      'name': 'Maintenance',
      'icon': Icons.build_rounded,
      'color': Color(0xFF92400E),
      'route': null,
    },
    {
      'name': 'Logistics',
      'icon': Icons.local_shipping_rounded,
      'color': Color(0xFFEA580C),
      'route': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Departments",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            // 4 kolom di HP, 5 di tablet, 6 di desktop
            final crossAxisCount = maxWidth > 900 ? 6 : maxWidth > 600 ? 5 : 4;
            final spacing = 12.0;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                // Agar item benar-benar kotak (square)
                childAspectRatio: 1.0,
              ),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final dept = departments[index];
                return _buildModernDepartmentItem(
                  context,
                  name: dept['name'] as String,
                  icon: dept['icon'] as IconData,
                  color: dept['color'] as Color,
                  route: dept['route'] as Widget Function()?,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ✨ BARU: Item dengan gaya DANA — kotak sempurna, ikon besar, teks rapi
  Widget _buildModernDepartmentItem(
    BuildContext context, {
    required String name,
    required IconData icon,
    required Color color,
    Widget Function()? route,
  }) {
    return GestureDetector(
      key: ValueKey('department_$name'),
      onTap: () {
        if (route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name - Halaman belum tersedia'),
              backgroundColor: const Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // ✅ Border tipis alih-alih shadow → lebih clean
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
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