import 'package:flutter/material.dart';

// --- Import screen-screen spesifik untuk Bonding ---
import 'summary/input_summary_bonding_screen.dart';
import 'reject/input_reject_bonding_screen.dart';

/// Home screen untuk departemen Bonding.
/// Menampilkan daftar sub-process yang dapat diakses.
class BondingHomeScreen extends StatefulWidget {
  const BondingHomeScreen({super.key});

  @override
  State<BondingHomeScreen> createState() => _BondingHomeScreenState();
}

class _BondingHomeScreenState extends State<BondingHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // === Premium App Bar with Glass Effect ===
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BackButton(
                color: const Color(0xFF1E293B),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6D28D9), // Deep Purple
                      Color(0xFF7C3AED), // Medium Purple
                      Color(0xFF8B5CF6), // Light Purple
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Glassmorphism Pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Floating Elements
                    _buildFloatingElements(),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 100, 28, 36),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                backdropFilter: const ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              ),
                              child: const Icon(
                                Icons.join_full_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Bonding Department",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                            Text(
                              "Production Management System",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // === Main Content with Premium Cards ===
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Quick Stats Cards ===
                      _buildStatsSection(),
                      const SizedBox(height: 32),

                      // === Section Header ===
                      _buildSectionHeader(
                        title: "Production Modules",
                        subtitle: "Select a module to manage production data",
                      ),
                      const SizedBox(height: 24),

                      // === Active Modules (Summary & Reject) ===
                      _buildActiveModuleCard(
                        context: context,
                        title: "Summary Report",
                        subtitle: "Input and view production summary data",
                        icon: Icons.analytics_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            _createRoute(const InputSummaryBondingScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildActiveModuleCard(
                        context: context,
                        title: "Reject (NG) Report",
                        subtitle: "Input and track Not Good / Reject items",
                        icon: Icons.report_gmailerrorred_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            _createRoute(const InputRejectBondingScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // === Coming Soon Section ===
                      _buildSectionHeader(
                        title: "Coming Soon",
                        subtitle: "Additional features will be available soon",
                      ),
                      const SizedBox(height: 24),

                      _buildComingSoonCard(
                        title: "Losstime Analysis",
                        subtitle: "Track and analyze production downtime",
                        icon: Icons.timer_off_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildComingSoonCard(
                        title: "Output Tracking",
                        subtitle: "Monitor production output and targets",
                        icon: Icons.trending_up_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildComingSoonCard(
                        title: "Quality Control",
                        subtitle: "Manage quality checks and standards",
                        icon: Icons.verified_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Floating circles
        Positioned(
          top: 80,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
              ),
              borderRadius: BorderRadius.circular(80),
              boxShadow: [
                BoxShadow(
                  color: const 