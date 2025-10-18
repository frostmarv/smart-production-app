// lib/screens/home_pages/home/home_page_content.dart
import 'package:flutter/material.dart';
import 'package:zinus_production/screens/home_pages/workable/bonding/workable_bonding_page.dart';
import 'package:zinus_production/screens/home_pages/more/more_home_page.dart';
import 'package:zinus_production/services/auth_service.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
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
                  "Hai !",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ Tampilkan nama user dari cache AuthService (tanpa panggil API)
                FutureBuilder<dynamic>(
                  future: AuthService.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Loading... 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }

                    String displayName = "User";
                    if (snapshot.hasData && snapshot.data is Map) {
                      final user = snapshot.data as Map;
                      displayName = user['name'] ??
                                   user['email']?.split('@').first ??
                                   "User";
                    }
                    // Jika error atau tidak ada data, tetap tampilkan "User"

                    return Text(
                      "$displayName 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  "Monitor your production in real-time",
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

          // === QUICK ACCESS SECTION ===
          const Text(
            "Quick Access :",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          // --- SECTION 1: WORKABLE ---
          _buildSectionHeader("Workable"),
          const SizedBox(height: 12),
          _buildDanaGrid(context, [
            _buildDanaItem(
              context,
              "Bonding",
              Icons.factory_rounded,
              const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkableBondingPage()),
                );
              },
            ),
            _buildDanaItem(
              context,
              "Packing Foam",
              Icons.inventory_rounded,
              const Color(0xFF10B981),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Packing Foam - Halaman belum siap')),
                );
              },
            ),
            _buildDanaItem(
              context,
              "Packing Spring",
              Icons.precision_manufacturing_rounded,
              const Color(0xFFF59E0B),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Packing Spring - Halaman belum siap')),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),

          // --- SECTION 2: DEPARTEMENS ---
          _buildSectionHeader("Departemens"),
          const SizedBox(height: 12),
          _buildDanaGrid(context, [
            _buildDanaItem(
              context,
              "Packing Foam",
              Icons.inventory_rounded,
              const Color(0xFF10B981),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Packing Foam - Halaman belum siap')),
                );
              },
            ),
            _buildDanaItem(
              context,
              "Packing Spring",
              Icons.precision_manufacturing_rounded,
              const Color(0xFFF59E0B),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Packing Spring - Halaman belum siap')),
                );
              },
            ),
            _buildDanaItem(
              context,
              "Bonding",
              Icons.build_rounded,
              const Color(0xFFF59E0B),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bonding - Halaman belum siap')),
                );
              },
            ),
            _buildDanaItem(
              context,
              "Lainnya",
              Icons.more_horiz_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoreHomeScreen()),
                );
              },
            ),
          ]),

          // === QUICK STATS ===
          const SizedBox(height: 32),
          const Text(
            "Quick Stats",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Active Lines",
                  "4",
                  Icons.precision_manufacturing_rounded,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Today's Target",
                  "85%",
                  Icons.track_changes_rounded,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Stat Card (tidak berubah)
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Section Header (tidak berubah)
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontSize: 16,
        ),
      ),
    );
  }

  // ✨ Dana Item (tidak berubah)
  Widget _buildDanaItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ✨ Dana Grid (tidak berubah)
  Widget _buildDanaGrid(BuildContext context, List<Widget> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final crossAxisCount = maxWidth > 800 ? 5 : 4;
        final spacing = 8.0;
        final itemWidth = (maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: item,
            );
          }).toList(),
        );
      },
    );
  }
}