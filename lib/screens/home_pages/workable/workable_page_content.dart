// lib/screens/home_pages/workable/workable_page_content.dart
import 'package:flutter/material.dart';
import './bonding/workable_bonding_page.dart';
import './packing_foam/workable_packing_foam_page.dart';
import './packing_spring/workable_packing_spring_page.dart';

class WorkablePageContent extends StatelessWidget {
  const WorkablePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFC),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header with Glassmorphism Effect
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFA855F7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Workable Tasks",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Production Management Hub",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Select a department to manage your workflow",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Premium Cards with Enhanced Design
            _buildPremiumMenuCard(
              context,
              title: "Workable Bonding",
              subtitle: "Manage and track bonding processes with real-time updates",
              icon: Icons.link_rounded,
              gradientColors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              isDisabled: false,
              badge: "Active",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkableBondingPage()),
              ),
            ),
            const SizedBox(height: 16),

            _buildPremiumMenuCard(
              context,
              title: "Workable Packing Foam",
              subtitle: "Oversee foam production line operations",
              icon: Icons.inventory_2_outlined,
              gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
              isDisabled: true,
              badge: "Soon",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkablePackingFoamPage()),
              ),
            ),
            const SizedBox(height: 16),

            _buildPremiumMenuCard(
              context,
              title: "Workable Packing Spring",
              subtitle: "Manage spring packing & assembly workflows",
              icon: Icons.compress_rounded,
              gradientColors: [const Color(0xFFF97316), const Color(0xFFEA580C)],
              isDisabled: true,
              badge: "Soon",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkablePackingSpringPage()),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    bool isDisabled = false,
    required String badge,
    required VoidCallback onTap,
  }) {
    return AnimatedOpacity(
      opacity: isDisabled ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDisabled 
                    ? Colors.black.withOpacity(0.05)
                    : gradientColors[0].withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Gradient Border Effect
                if (!isDisabled)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors,
                        ),
                      ),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Icon Container with Gradient
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDisabled
                                ? [Colors.grey.shade300, Colors.grey.shade400]
                                : gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDisabled
                                  ? Colors.transparent
                                  : gradientColors[0].withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDisabled
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF1E293B),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isDisabled
                                        ? LinearGradient(
                                            colors: [
                                              Colors.grey.shade200,
                                              Colors.grey.shade300,
                                            ],
                                          )
                                        : LinearGradient(
                                            colors: [
                                              gradientColors[0].withOpacity(0.15),
                                              gradientColors[1].withOpacity(0.15),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDisabled
                                          ? Colors.grey.shade400
                                          : gradientColors[0].withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDisabled
                                          ? Colors.grey.shade600
                                          : gradientColors[1],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDisabled
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Arrow Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey.shade100
                              : gradientColors[0].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDisabled
                              ? Icons.lock_outline_rounded
                              : Icons.arrow_forward_rounded,
                          color: isDisabled
                              ? Colors.grey.shade400
                              : gradientColors[1],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
