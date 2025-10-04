// lib/screens/home_pages/workable/workable_page_content.dart
import 'package:flutter/material.dart';
import './bonding/workable_bonding_page.dart';
import './packing_foam/workable_packing_foam_page.dart';
import './packing_spring/workable_packing_spring_page.dart';

class WorkablePageContent extends StatelessWidget {
  const WorkablePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text(
          'Workable',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspaces_outlined,
              color: Color(0xFF6366F1),
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header with Glassmorphism & Icon
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.workspaces_rounded,
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
                              "Production Hub",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Manage your workflow across departments",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                      borderRadius: BorderRadius.circular(14),
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

            // Premium Cards
            _buildPremiumMenuCard(
              context,
              title: "Bonding",
              subtitle: "Manage and track bonding processes with real-time updates",
              icon: Icons.polymer_rounded,
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
              title: "Packing Foam",
              subtitle: "Oversee foam production line operations",
              icon: Icons.layers_rounded,
              gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
              isDisabled: true,
              badge: "Soon",
              onTap: null,
            ),
            const SizedBox(height: 16),

            _buildPremiumMenuCard(
              context,
              title: "Packing Spring",
              subtitle: "Manage spring packing & assembly workflows",
              icon: Icons.auto_fix_high_rounded,
              gradientColors: [const Color(0xFFF97316), const Color(0xFFEA580C)],
              isDisabled: true,
              badge: "Soon",
              onTap: null,
            ),

            const SizedBox(height: 40),
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
    VoidCallback? onTap,
  }) {
    return AnimatedOpacity(
      opacity: isDisabled ? 0.75 : 1.0,
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
                    ? Colors.black.withOpacity(0.04)
                    : gradientColors[0].withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Left accent bar
                if (!isDisabled)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
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
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDisabled
                                ? [Colors.grey.shade200, Colors.grey.shade300]
                                : gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isDisabled
                              ? []
                              : [
                                  BoxShadow(
                                    color: gradientColors[0].withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 18),

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
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isDisabled
                                        ? null
                                        : LinearGradient(
                                            colors: [
                                              gradientColors[0].withOpacity(0.12),
                                              gradientColors[1].withOpacity(0.12),
                                            ],
                                          ),
                                    color: isDisabled ? Colors.grey.shade100 : null,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDisabled
                                          ? Colors.grey.shade300
                                          : gradientColors[0].withOpacity(0.25),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Action Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey.shade100
                              : gradientColors[0].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDisabled
                              ? Icons.lock_clock_rounded
                              : Icons.arrow_forward_ios_rounded,
                          color: isDisabled
                              ? Colors.grey.shade400
                              : gradientColors[1],
                          size: isDisabled ? 20 : 18,
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