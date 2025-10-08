// lib/screens/home_pages/workable/bonding/workable_bonding_detail.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/workable/workable_bonding_repository.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
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
  ConnectionState _prevConnectionState = ConnectionState.none;

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
    // ✅ Tanpa setState — langsung assign future
    _workableBondingDetailFuture = WorkableBondingRepository.getWorkableBondingDetail();
  }

  Future<void> _captureAndShare() async {
    try {
      Uint8List? image = await _screenshotController.capture();
      if (image == null) {
        _showMessage('Gagal mengambil tangkapan layar.');
        return;
      }

      await Share.shareXFiles([
        XFile.fromData(
          image,
          mimeType: 'image/png',
          name: 'workable_detail_summary.png',
        ),
      ], text: 'Ini adalah detail produksi Workable Bonding');
      _showMessage('Gambar telah dibagikan!');
    } catch (e) {
      _showMessage('Gagal membagikan gambar: $e');
    }
  }

  Future<void> _downloadImage() async {
    try {
      Uint8List? image = await _screenshotController.capture();
      if (image == null) return;

      // ✅ Tidak perlu permission — simpan ke ApplicationDocumentsDirectory
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

  void _showFullTableLandscapePopup(List<dynamic> items) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Workable Detail - Full View",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Header sesuai contoh JSON:
                        // customerPO, shipToName, sku, week, quantityOrder, Layer 1-4, Hole, remain, remarks, status
                        Container(
                          color: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 100, child: _popupHeaderCell('CUSTOMER PO')),
                              SizedBox(width: 160, child: _popupHeaderCell('SHIP TO')),
                              SizedBox(width: 120, child: _popupHeaderCell('SKU')),
                              SizedBox(width: 60, child: _popupHeaderCell('WEEK')),
                              SizedBox(width: 80, child: _popupHeaderCell('QTY', textAlign: TextAlign.end)),
                              SizedBox(width: 60, child: _popupHeaderCell('L1', textAlign: TextAlign.end)),
                              SizedBox(width: 60, child: _popupHeaderCell('L2', textAlign: TextAlign.end)),
                              SizedBox(width: 60, child: _popupHeaderCell('L3', textAlign: TextAlign.end)),
                              SizedBox(width: 60, child: _popupHeaderCell('L4', textAlign: TextAlign.end)),
                              SizedBox(width: 60, child: _popupHeaderCell('HOLE', textAlign: TextAlign.end)),
                              SizedBox(width: 80, child: _popupHeaderCell('REMAIN', textAlign: TextAlign.end)),
                              SizedBox(width: 140, child: _popupHeaderCell('REMARKS')),
                              SizedBox(width: 100, child: _popupHeaderCell('STATUS')),
                            ],
                          ),
                        ),
                        // Rows
                        ...items.map((item) {
                          final data = item as Map<String, dynamic>;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: _popupDataCell(data['customerPO'] ?? '-')),
                                SizedBox(width: 160, child: _popupDataCell(data['shipToName'] ?? '-')),
                                SizedBox(width: 120, child: _popupDataCell(data['sku'] ?? '-')),
                                SizedBox(width: 60, child: _popupDataCell(data['week'].toString())),
                                SizedBox(
                                  width: 80,
                                  child: _popupDataCell(
                                    numberFormat.format(data['quantityOrder'] ?? 0),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: _popupDataCell(
                                    (data['Layer 1'] ?? 0).toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: _popupDataCell(
                                    (data['Layer 2'] ?? 0).toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: _popupDataCell(
                                    (data['Layer 3'] ?? 0).toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: _popupDataCell(
                                    (data['Layer 4'] ?? 0).toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: _popupDataCell(
                                    (data['Hole'] ?? 0).toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: _popupDataCell(
                                    numberFormat.format(data['remain'] ?? 0),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(width: 140, child: _popupDataCell(data['remarks'] ?? '-')),
                                SizedBox(width: 100, child: _buildStatusChip(data['status'] ?? 'Unknown')),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _popupHeaderCell(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
          fontSize: 12,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _popupDataCell(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF1E293B),
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ✅ Reusable status chip — dipakai di tabel & popup
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

    return Container(
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
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _captureAndShare();
                  break;
                case 'download':
                  _downloadImage();
                  break;
                case 'refresh':
                  _fetchData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, color: Color(0xFF6366F1)),
                    SizedBox(width: 12),
                    Text("Bagikan Gambar"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 12),
                    Text("Download Gambar"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Text("Refresh Data"),
                  ],
                ),
              ),
            ],
            tooltip: "Opsi",
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
          const SizedBox(width: 12),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<List<dynamic>>(
        future: _workableBondingDetailFuture,
        builder: (context, snapshot) {
          // ✅ Kontrol animasi hanya saat state berubah
          if (_prevConnectionState == ConnectionState.waiting &&
              (snapshot.hasData || snapshot.hasError)) {
            _animationController.forward();
          } else if (snapshot.connectionState == ConnectionState.waiting &&
                     _prevConnectionState != ConnectionState.waiting) {
            _animationController.stop();
          }
          _prevConnectionState = snapshot.connectionState;
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
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: snapshot.hasData && snapshot.data != null
                  ? () => _showFullTableLandscapePopup(snapshot.data!)
                  : null,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text("Detail View"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ),
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
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
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
              Theme(
                data: ThemeData.light(),
                child: Screenshot(
                  controller: _screenshotController,
                  child: _buildTableContent(snapshot),
                ),
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
          _buildTableHeader(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          ...items.map((item) => _buildTableRow(item, numberFormat)).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(flex: 2, child: _headerCell('CUSTOMER PO')),
        Expanded(flex: 2, child: _headerCell('SHIP TO')),
        Expanded(flex: 2, child: _headerCell('SKU')),
        Expanded(flex: 1, child: _headerCell('WEEK')),
        Expanded(flex: 1, child: _headerCell('QTY', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L1', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L2', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L3', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('L4', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('HOLE', textAlign: TextAlign.end)),
        Expanded(flex: 1, child: _headerCell('REMAIN', textAlign: TextAlign.end)),
        Expanded(flex: 2, child: _headerCell('REMARKS')),
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
            Expanded(flex: 2, child: _dataCell(item['shipToName'] ?? '-')),
            Expanded(flex: 2, child: _dataCell(item['sku'] ?? '-')),
            Expanded(flex: 1, child: _dataCell(item['week'].toString())),
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
                (item['Layer 1'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                (item['Layer 2'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                (item['Layer 3'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                (item['Layer 4'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            Expanded(
              flex: 1,
              child: _dataCell(
                (item['Hole'] ?? 0).toString(),
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
            Expanded(flex: 2, child: _dataCell(item['remarks'] ?? '-')),
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
          Expanded(flex: 2, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 1, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSkeletonElement()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildSkeletonElement()),
        ],
      ),
    );
  }

  Widget _buildSkeletonElement() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}  