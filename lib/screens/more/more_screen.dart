// lib/screens/more/more_screen.dart
import 'package:flutter/material.dart';
import 'package:zinus_production/services/auth_service.dart'; // Import AuthService
import 'profile_screen.dart'; // 🔥 Import ProfileScreen

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // Ubah _buildMenuItem menjadi static
  static Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    return GestureDetector(
      onTap: () async {
        if (title == "Logout") {
          await AuthService.logout();
          // 🔥 GANTI: Hapus semua stack dan arahkan ke login
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title feature will be available soon."),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
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
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 GANTI: Jadikan profil bisa di-klik
          GestureDetector(
            // onTap: () => Navigator.pushNamed(context, '/profile'), // 👈 Jika kamu pakai named route
            onTap: () {
              // Navigasi ke ProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: FutureBuilder<Map<String, dynamic>?>(
              future: AuthService.getUser(),
              builder: (context, snapshot) {
                String userName = "User Profile";
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  userName = snapshot.data?['name'] ?? "User Profile"; // Ganti 'name' sesuai API kamu
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName, // Menggunakan nama pengguna dari AuthService
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Smart Production System",
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      // Tambahkan ikon panah untuk menunjukkan bahwa ini bisa di-klik
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Menu Items
          const Text(
            "Settings & More",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          MoreScreen._buildMenuItem(context, icon: Icons.settings_rounded, title: "Settings", subtitle: "App preferences and configuration", color: const Color(0xFF64748B)),
          const SizedBox(height: 12),
          MoreScreen._buildMenuItem(context, icon: Icons.help_outline_rounded, title: "Help & Support", subtitle: "Get help and contact support", color: const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          MoreScreen._buildMenuItem(context, icon: Icons.info_outline_rounded, title: "About", subtitle: "App version and information", color: const Color(0xFF10B981)),
          const SizedBox(height: 12),
          MoreScreen._buildMenuItem(context, icon: Icons.logout_rounded, title: "Logout", subtitle: "Sign out of your account", color: const Color(0xFFEF4444)),
        ],
      ),
    );
  }
}