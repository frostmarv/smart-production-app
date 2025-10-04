// lib/screens/home_pages/workable/workable_page_content.dart
import 'package:flutter/material.dart';
import './bonding/workable_bonding_page.dart';
import './packing_foam/workable_packing_foam_page.dart';
import './packing_spring/workable_packing_spring_page.dart';

class WorkablePageContent extends StatelessWidget {
  const WorkablePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Workable Tasks",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select a task to manage your production workflow",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Cards
          _buildMenuCard(
            context,
            title: "Workable Bonding",
            subtitle: "Manage and track bonding processes.",
            icon: Icons.link_rounded,
            color: const Color(0xFF3B82F6),
            isDisabled: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkableBondingPage()),
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuCard(
            context,
            title: "Workable Packing Foam",
            subtitle: "Oversee foam production line.",
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF10B981),
            isDisabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkablePackingFoamPage()),
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuCard(
            context,
            title: "Workable Packing Spring",
            subtitle: "Manage spring packing & assembly.",
            icon: Icons.compress_rounded,
            color: const Color(0xFFF97316),
            isDisabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkablePackingSpringPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (isDisabled) ...[ // Perbaikan: Mengganti ..[ dengan ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Coming Soon",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF854D0E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isDisabled ? Icons.lock_outline_rounded : Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF94A3B8),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
