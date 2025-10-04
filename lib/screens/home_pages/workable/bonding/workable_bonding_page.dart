// lib/screens/home_pages/workable/bonding/workable_bonding_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_production_app/repositories/workable/workable_bonding_repository.dart';
import 'workable_bonding_detail.dart'; // path sudah benar

class WorkableBondingPage extends StatefulWidget {
  const WorkableBondingPage({super.key});

  @override
  State<WorkableBondingPage> createState() => _WorkableBondingPageState();
}

class _WorkableBondingPageState extends State<WorkableBondingPage>
    with TickerProviderStateMixin {
  late Future<List<dynamic>> _workableBondingFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchData() {
    setState(() {
      _workableBondingFuture = WorkableBondingRepository.getWorkableBonding();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Workable Bonding",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF2563EB),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _fetchData,
              tooltip: "Refresh Data",
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<List<dynamic>>(
        future: _workableBondingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            _animationController.value = 0;
          } else {
            _animationController.forward();
          }
          return _buildDashboardView(snapshot);
        },
      ),
    );
  }

  Widget _buildDashboardView(AsyncSnapshot<List<dynamic>> snapshot) {
    final items = snapshot.hasData && snapshot.data != null ? snapshot.data! : [];
    final total = items.length;
    final running = items.where((item) =>
        ['running', 'in progress'].contains((item['status'] ?? '').toLowerCase())).length;
    final notStarted = items.where((item) =>
        (item['status'] ?? '').toLowerCase() == 'not started').length;
    final completed = items.where((item) =>
        (item['status'] ?? '').toLowerCase() == 'completed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(total, running, notStarted, completed),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF2563EB).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.table_chart_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detailed View",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "View complete workable details",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WorkableBondingDetailPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "View",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTableContainer(snapshot),
        ],
      ),
    );
  }

  Widget _buildTableContainer(AsyncSnapshot<List<dynamic>> snapshot) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF8FAFC),
                      Colors.white,
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.summarize_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Workable Summary",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
              _buildTableContent(snapshot)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableContent(AsyncSnapshot<List<dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildSkeletonLoader();
    }
    if (snapshot.hasError) {
      return _buildErrorState();
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildDataTable(snapshot.data!),
    );
  }

  DataTable _buildDataTable(List<dynamic> items) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return DataTable(
      dataRowMaxHeight: 64,
      columnSpacing: 24,
      headingRowHeight: 50,
      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        fontSize: 13,
      ),
      columns: const [
        DataColumn(label: Text('WEEK')),
        DataColumn(label: Text('SHIP TO NAME')),
        DataColumn(label: Text('SKU')),
        DataColumn(label: Text('QTY ORDER'), numeric: true),
        DataColumn(label: Text('REMAIN'), numeric: true),
        DataColumn(label: Text('STATUS')),
      ],
      rows: items.asMap().entries.map((entry) {
        final item = entry.value;
        final isEven = entry.key % 2 == 0;
        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.hovered)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            }
            return isEven ? Colors.grey.withOpacity(0.05) : null;
          }),
          cells: [
            DataCell(Text(item['week'].toString())),
            DataCell(Text(item['shipToName'] ?? '-')),
            DataCell(Text(item['sku'] ?? '-')),
            DataCell(Text(numberFormat.format(item['quantityOrder'] ?? 0))),
            DataCell(Text(numberFormat.format(item['remain'] ?? 0))),
            DataCell(_buildStatusChip(item['status'] ?? 'Unknown')),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection(int total, int running, int notStarted, int completed) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                "Total Items",
                total,
                Icons.view_list_rounded,
                const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSummaryCard(
                "Running",
                running,
                Icons.play_circle_outline_rounded,
                const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                "Not Started",
                notStarted,
                Icons.hourglass_empty_rounded,
                const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSummaryCard(
                "Completed",
                completed,
                Icons.check_circle_outline_rounded,
                const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor, textColor;
    final lower = status.toLowerCase();
    if (lower == 'not started') {
      bgColor = const Color(0xFFFEF9C3);
      textColor = const Color(0xFF854D0E);
    } else if (lower == 'running' || lower == 'in progress') {
      bgColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1E40AF);
    } else if (lower == 'completed') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else {
      bgColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF334155);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---- Functions added to fix compile errors ----

  Widget _buildSkeletonLoader() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        'Failed to load data. Please try again.',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No workable data available.'),
    );
  }
}
