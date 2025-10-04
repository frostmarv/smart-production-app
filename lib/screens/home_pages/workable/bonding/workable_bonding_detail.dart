// lib/screens/home_pages/workable/bonding/workable_bonding_detail.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/workable/workable_bonding_repository.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class WorkableBondingDetailPage extends StatefulWidget {
  const WorkableBondingDetailPage({super.key});

  @override
  State<WorkableBondingDetailPage> createState() => _WorkableBondingDetailPageState();
}

class _WorkableBondingDetailPageState extends State<WorkableBondingDetailPage>
    with TickerProviderStateMixin {
  late Future<List<dynamic>> _workableBondingDetailFuture;
  late AnimationController _animationController;
  final ScreenshotController _screenshotController = ScreenshotController();

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

  Future<void> _captureAndShare() async {
    try {
      Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final tempFile = File('${dir.path}/temp_workable_detail.png');
      await tempFile.writeAsBytes(image);

      await Share.shareXFiles([
        XFile.fromData(
          image,
          mimeType: 'image/png',
          name: 'workable_detail_summary.png',
        ),
      ], text: 'Ini adalah detail produksi Workable Bonding');

      await tempFile.delete();

      _showMessage('Gambar telah dibagikan!');
    } catch (e) {
      _showMessage('Gagal membagikan gambar: $e');
    }
  }

  Future<void> _downloadImage() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showMessage('Izin penyimpanan dibutuhkan untuk menyimpan gambar.');
        return;
      }
    }

    try {
      Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/workable_bonding_detail.png');
      await file.writeAsBytes(image);

      _showMessage('Gambar disimpan di:\n${file.path}');
    } catch (e) {
      _showMessage('Gagal menyimpan gambar: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Workable Bonding Detail",
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
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
          ),
        ),
        actions: [
          // Tombol Share
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _captureAndShare,
            tooltip: "Bagikan Gambar",
            color: Colors.white,
          ),
          // Tombol Download
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _downloadImage,
            tooltip: "Download as Image",
            color: Colors.white,
          ),
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
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.8,
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
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.08),
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
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Production Details",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
              ),
              Screenshot(
                controller: _screenshotController,
                child: _buildTableContent(snapshot),
              ),
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

    final items = snapshot.data!;
    final numberFormat = NumberFormat("#,##0", "en_US");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          _buildTableHeader(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          // Rows
          ...items.map((item) => _buildTableRow(item, numberFormat)).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(flex: 2, child: _headerCell('CUSTOMER PO')),
        Expanded(flex: 2, child: _headerCell('SKU')),
        Expanded(flex: 1, child: _headerCell('QTY', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L1', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L2', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L3', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L4', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('HOLE', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('REMAIN', textAlign: TextAlign.end)),
        Expanded(flex: 2, child: _headerCell('STATUS')),
      ],
    );
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
          fontSize: 12,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableRow(dynamic item, NumberFormat numberFormat) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _dataCell(item['customerPO'] ?? '-')),
            Expanded(flex: 2, child: _dataCell(item['sku'] ?? '-')),
            Expanded(
              flex: 1,
              child: _dataCell(
                numberFormat.format(item['quantityOrder'] ?? 0),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                item['Layer 1']?.toString() ?? '0',
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                item['Layer 2']?.toString() ?? '0',
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                item['Layer 3']?.toString() ?? '0',
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                item['Layer 4']?.toString() ?? '0',
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                item['Hole']?.toString() ?? '0',
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                numberFormat.format(item['remain'] ?? 0),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(flex: 2, child: _buildStatusChip(item['status'] ?? 'Unknown')),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _dataCell(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1E293B),
          height: 1.3,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor, textColor;
    final lower = status.toLowerCase();
    if (lower == 'not started') {
      bgColor = const Color(0xFFFFF9DB);
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          textAlign: TextAlign.center,
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
          Expanded(flex: 2, child: _buildSkeletonElement(width: 100)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _buildSkeletonElement(width: 100)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 50)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 40)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 40)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 40)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 40)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 40)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildSkeletonElement(width: 40)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _buildSkeletonElement(width: 80)),
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