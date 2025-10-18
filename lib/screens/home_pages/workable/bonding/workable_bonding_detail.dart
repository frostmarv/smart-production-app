// lib/screens/home_pages/workable/bonding/workable_bonding_detail.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/workable/workable_bonding_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'workable_bonding_reject.dart';

class WorkableBondingDetailPage extends StatefulWidget {
  const WorkableBondingDetailPage({super.key});

  @override
  State<WorkableBondingDetailPage> createState() => _WorkableBondingDetailPageState();
}

class _WorkableBondingDetailPageState extends State<WorkableBondingDetailPage>
    with TickerProviderStateMixin {
  late Future<List<dynamic>> _bondingDataFuture;
  late AnimationController _animationController;
  final GlobalKey _captureKey = GlobalKey(); // 🔑 Untuk seluruh konten (bukan hanya tabel)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadData();
  }

  void _loadData() {
    _bondingDataFuture = WorkableBondingRepository.getWorkableBondingDetail().then((data) {
      if (!mounted) return data;
      if (_animationController.isDismissed) {
        _animationController.forward();
      }
      return data;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Tangkap SELURUH konten (termasuk off-screen)
  Future<Uint8List?> _captureFullContent() async {
    if (kIsWeb) {
      _showMessage('Fitur screenshot tidak didukung di web.');
      return null;
    }

    try {
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showMessage('Gagal mengambil tangkapan layar. Widget tidak ditemukan.');
        return null;
      }

      // Gunakan pixelRatio tinggi untuk kualitas tajam
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      _showMessage('Gagal mengambil tangkapan layar: $e');
      return null;
    }
  }

  Future<void> _captureAndShare() async {
    if (kIsWeb) {
      _showMessage('Fitur bagikan gambar tidak didukung di web.');
      return;
    }

    final image = await _captureFullContent();
    if (image == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/workable_bonding_detail.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Ini adalah detail produksi Workable Bonding',
      );
      _showMessage('Gambar telah dibagikan!');
    } catch (e) {
      _showMessage('Gagal membagikan: $e');
    }
  }

  Future<void> _downloadImage() async {
    if (kIsWeb) {
      _showMessage('Fitur unduh gambar tidak didukung di web.');
      return;
    }

    final image = await _captureFullContent();
    if (image == null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/workable_bonding_detail.png');
      await file.writeAsBytes(image);
      _showMessage('Gambar disimpan di:\n${file.path}');
    } catch (e) {
      _showMessage('Gagal menyimpan gambar: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
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

  Widget _buildTableHeader() {
    return Row(
      children: [
        SizedBox(width: 160, child: _headerCell('SHIP TO')),
        SizedBox(width: 120, child: _headerCell('SKU')),
        SizedBox(width: 60, child: _headerCell('WEEK')),
        SizedBox(width: 80, child: _headerCell('QTY', textAlign: TextAlign.end)),
        SizedBox(width: 60, child: _headerCell('L1', textAlign: TextAlign.end)),
        SizedBox(width: 60, child: _headerCell('L2', textAlign: TextAlign.end)),
        SizedBox(width: 60, child: _headerCell('L3', textAlign: TextAlign.end)),
        SizedBox(width: 60, child: _headerCell('L4', textAlign: TextAlign.end)),
        SizedBox(width: 60, child: _headerCell('HOLE', textAlign: TextAlign.end)),
        SizedBox(width: 80, child: _headerCell('REMAIN', textAlign: TextAlign.end)),
        SizedBox(width: 140, child: _headerCell('REMARKS')),
        SizedBox(width: 120, child: _headerCell('STATUS')),
      ],
    );
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
          fontSize: 13,
          letterSpacing: 0.3,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableRow(dynamic item, NumberFormat numberFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 160, child: _dataCell(item['shipToName'] ?? '-')),
            SizedBox(width: 120, child: _dataCell(item['sku'] ?? '-')),
            SizedBox(width: 60, child: _dataCell(item['week'].toString())),
            SizedBox(
              width: 80,
              child: _dataCell(
                numberFormat.format(item['quantityOrder'] ?? 0),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 60,
              child: _dataCell(
                (item['Layer 1'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 60,
              child: _dataCell(
                (item['Layer 2'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 60,
              child: _dataCell(
                (item['Layer 3'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 60,
              child: _dataCell(
                (item['Layer 4'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 60,
              child: _dataCell(
                (item['Hole'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 80,
              child: _dataCell(
                numberFormat.format(item['Remain Produksi'] ?? 0),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(width: 140, child: _dataCell(item['remarks'] ?? '-')),
            SizedBox(width: 120, child: _buildStatusChip(item['status'] ?? 'Unknown')),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _dataCell(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1E293B),
          height: 1.4,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 160, child: _skeletonCell()),
            SizedBox(width: 120, child: _skeletonCell()),
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 140, child: _skeletonCell()),
            SizedBox(width: 120, child: _skeletonCell()),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _skeletonCell() {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: Colors.red.withOpacity(0.6), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_chart, color: const Color(0xFF94A3B8), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildTableContainer(List<dynamic> items) {
    final numberFormat = NumberFormat("#,##0", "en_US");

    return Container(
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTableHeader(),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                      if (items.isEmpty)
                        _buildEmptyPlaceholder('Tidak ada data detail tersedia.')
                      else
                        ...items.map((item) => _buildTableRow(item, numberFormat)).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(List<dynamic> items) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    final totalQuantity = items.fold<int>(0, (sum, item) => sum + ((item['quantityOrder'] ?? 0) as num).toInt());
    final totalItems = items.length;
    final runningItems = items.where((item) =>
        ['running', 'in progress'].contains((item['status'] ?? '').toLowerCase())).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(totalItems, totalQuantity, runningItems),
              const SizedBox(height: 24),
              _buildTableContainer(items),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkableBondingRejectPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.warning_amber_rounded, size: 18),
                  label: const Text("View NG & Replacement"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardView(AsyncSnapshot<List<dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _buildErrorPlaceholder('Gagal memuat data: ${snapshot.error}');
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _buildErrorPlaceholder('Tidak ada data tersedia.');
    }

    final items = snapshot.data!;

    // ✅ Seluruh konten yang bisa di-capture
    return RepaintBoundary(
      key: _captureKey,
      child: Container(
        color: Colors.white, // Latar putih penuh untuk screenshot
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 30),
          child: _buildDashboardContent(items),
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
                  _loadData();
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
        future: _bondingDataFuture,
        builder: (context, snapshot) {
          return _buildDashboardView(snapshot);
        },
      ),
    );
  }
}