
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_production_app/repositories/workable/workable_bonding_repository.dart';

class WorkableBondingDetailPage extends StatefulWidget {
  WorkableBondingDetailPage({super.key});

  @override
  State<WorkableBondingDetailPage> createState() => _WorkableBondingDetailPageState();
}

class _WorkableBondingDetailPageState extends State<WorkableBondingDetailPage> with TickerProviderStateMixin {
  late Future<List<dynamic>> _workableBondingDetailFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      _workableBondingDetailFuture = WorkableBondingRepository.getWorkableBondingDetail();
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workable Bonding Detail",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<List<dynamic>>(
        future: _workableBondingDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            _animationController.stop();
          } else if (snapshot.hasData || snapshot.hasError) {
            _animationController.forward();
          }
          return _buildDashboardView(snapshot);
        },
      ),
    );
  }

  Widget _buildDashboardView(AsyncSnapshot<List<dynamic>> snapshot) {
    final items = snapshot.hasData && snapshot.data != null ? snapshot.data! : [];
    final totalQuantity = items.fold<int>(0, (sum, item) => sum + ((item['quantityOrder'] ?? 0) as num).toInt());
    final totalItems = items.length;
    final runningItems = items.where((item) => (item['status'] ?? '').toLowerCase() == 'running' || (item['status'] ?? '').toLowerCase() == 'in progress').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(totalItems, totalQuantity, runningItems),
          const SizedBox(height: 24),
          _buildTableContainer(snapshot),
        ],
      ),
    );
  }

  Widget _buildTableContainer(AsyncSnapshot<List<dynamic>> snapshot) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        width: double.infinity,
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
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Production Details",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                  ),
                ),
                _buildTableContent(snapshot)
              ],
            )),
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
    if (snapshot.data!.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildDataTable(snapshot.data!),
    );
  }

  DataTable _buildDataTable(List<dynamic> items) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    int rowIndex = 0;
    return DataTable(
      dataRowMaxHeight: 60,
      columnSpacing: 28.0,
      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
      headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13),
      columns: const [
        DataColumn(label: Text('CUSTOMER PO')),
        DataColumn(label: Text('SKU')),
        DataColumn(label: Text('QTY'), numeric: true),
        DataColumn(label: Text('L1'), numeric: true),
        DataColumn(label: Text('L2'), numeric: true),
        DataColumn(label: Text('L3'), numeric: true),
        DataColumn(label: Text('L4'), numeric: true),
        DataColumn(label: Text('HOLE'), numeric: true),
        DataColumn(label: Text('REMAIN'), numeric: true),
        DataColumn(label: Text('STATUS')),
      ],
      rows: items.map((item) {
        rowIndex++;
        final isEven = rowIndex % 2 == 0;
        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            }
            return isEven ? Colors.grey.withOpacity(0.05) : null;
          }),
          cells: [
            DataCell(Text(item['customerPO'] ?? '')),
            DataCell(Text(item['sku'] ?? '')),
            DataCell(Text(numberFormat.format(item['quantityOrder'] ?? 0))),
            DataCell(Text(item['Layer 1']?.toString() ?? '0')),
            DataCell(Text(item['Layer 2']?.toString() ?? '0')),
            DataCell(Text(item['Layer 3']?.toString() ?? '0')),
            DataCell(Text(item['Layer 4']?.toString() ?? '0')),
            DataCell(Text(item['Hole']?.toString() ?? '0')),
            DataCell(Text(numberFormat.format(item['remain'] ?? 0))),
            DataCell(_buildStatusChip(item['status'] ?? 'Unknown')),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection(int totalItems, int totalQuantity, int runningItems) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return Row(
      children: [
        Expanded(child: _buildSummaryCard("Total SKUs", totalItems.toString(), Icons.inventory_2_outlined, const Color(0xFF334155))),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard("Total Quantity", numberFormat.format(totalQuantity), Icons.format_list_numbered_rounded, const Color(0xFF047857))),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard("Running", runningItems.toString(), Icons.directions_run_rounded, const Color(0xFF2563EB))),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'not started':
        chipColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        break;
      case 'running':
      case 'in progress':
        chipColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        break;
      case 'completed':
        chipColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      default:
        chipColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF334155);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
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

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(5, (index) => const _SkeletonRow()),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Color(0xFF64748B), size: 40),
            const SizedBox(height: 16),
            const Text(
              "Gagal Memuat Detail",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text("Mohon periksa koneksi Anda dan coba lagi.", style: TextStyle(color: Color(0xFF64748B)), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Coba Lagi"),
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50.0),
      child: Center(
        child: Text("Tidak ada data detail yang tersedia.", style: TextStyle(color: Color(0xFF64748B))),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          _buildSkeletonElement(width: 80),
          const SizedBox(width: 20),
          _buildSkeletonElement(width: 100),
          const SizedBox(width: 20),
          _buildSkeletonElement(width: 50),
          const SizedBox(width: 20),
          Expanded(child: _buildSkeletonElement()),
        ],
      ),
    );
  }

  Widget _buildSkeletonElement({double? width}) {
    return Container(
      height: 20,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
