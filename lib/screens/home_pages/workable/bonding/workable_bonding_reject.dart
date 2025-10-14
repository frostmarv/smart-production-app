// lib/screens/home_pages/workable/bonding/workable_bonding_reject.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/workable/workable_bonding_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WorkableBondingRejectPage extends StatefulWidget {
  const WorkableBondingRejectPage({super.key});

  @override
  State<WorkableBondingRejectPage> createState() => _WorkableBondingRejectPageState();
}

class _WorkableBondingRejectPageState extends State<WorkableBondingRejectPage>
    with TickerProviderStateMixin {
  List<dynamic>? _rejectData; // ✅ Simpan data ke state
  late AnimationController _animationController;
  final GlobalKey _screenshotKey = GlobalKey();

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

  Future<void> _fetchData() async {
    try {
      final data = await WorkableBondingRepository.getWorkableBondingReject();
      if (mounted) {
        setState(() {
          _rejectData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rejectData = null;
        });
      }
      _showMessage('Gagal memuat data NG & Replacement: $e');
    }
  }

  // ✅ Capture tabel dari offscreen — pastikan data sudah siap
  Future<Uint8List?> _captureTable() async {
    if (_rejectData == null) {
      debugPrint("❌ Data NG & Replacement belum tersedia untuk di-capture");
      return null;
    }

    // Tunggu layout selesai + delay kecil untuk keandalan
    await Future.delayed(const Duration(milliseconds: 200));

    final boundary = _screenshotKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint("❌ RepaintBoundary tidak ditemukan");
      return null;
    }

    try {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      return null;
    }
  }

  Future<void> _captureAndShare() async {
    try {
      final image = await _captureTable();
      if (image == null) {
        _showMessage('Gagal mengambil tangkapan layar.');
        return;
      }

      await Share.shareXFiles([
        XFile.fromData(
          image,
          mimeType: 'image/png',
          name: 'workable_reject_summary.png',
        ),
      ], text: 'Ini adalah data NG & Replacement Workable Bonding');
      _showMessage('Gambar telah dibagikan!');
    } catch (e) {
      _showMessage('Gagal membagikan gambar: $e');
    }
  }

  Future<void> _downloadImage() async {
    try {
      final image = await _captureTable();
      if (image == null) {
        _showMessage('Gagal mengambil tangkapan layar.');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/workable_bonding_reject.png');
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

  // --- Widget helpers (tidak berubah) ---
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
        SizedBox(width: 60, child: _headerCell('Week')),
        SizedBox(width: 160, child: _headerCell('Ship To')),
        SizedBox(width: 140, child: _headerCell('SKU')),
        SizedBox(width: 100, child: _headerCell('Order Qty', textAlign: TextAlign.end)),
        // NG Layers
        SizedBox(width: 80, child: _headerCell('NG L1', textAlign: TextAlign.end)),
        SizedBox(width: 80, child: _headerCell('NG L2', textAlign: TextAlign.end)),
        SizedBox(width: 80, child: _headerCell('NG L3', textAlign: TextAlign.end)),
        SizedBox(width: 80, child: _headerCell('NG L4', textAlign: TextAlign.end)),
        SizedBox(width: 80, child: _headerCell('NG Hole', textAlign: TextAlign.end)),
        // Replacement Layers
        SizedBox(width: 100, child: _headerCell('Rep L1', textAlign: TextAlign.end)),
        SizedBox(width: 100, child: _headerCell('Rep L2', textAlign: TextAlign.end)),
        SizedBox(width: 100, child: _headerCell('Rep L3', textAlign: TextAlign.end)),
        SizedBox(width: 100, child: _headerCell('Rep L4', textAlign: TextAlign.end)),
        SizedBox(width: 100, child: _headerCell('Rep Hole', textAlign: TextAlign.end)),
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
            SizedBox(width: 60, child: _dataCell(item['week'].toString())),
            SizedBox(width: 160, child: _dataCell(item['shipToName'] ?? '-')),
            SizedBox(width: 140, child: _dataCell(item['sku'] ?? '-')),
            SizedBox(
              width: 100,
              child: _dataCell(
                numberFormat.format(item['quantityOrder'] ?? 0),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 80,
              child: _dataCell(
                (item['NG Layer 1'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 80,
              child: _dataCell(
                (item['NG Layer 2'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 80,
              child: _dataCell(
                (item['NG Layer 3'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 80,
              child: _dataCell(
                (item['NG Layer 4'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 80,
              child: _dataCell(
                (item['NG Hole'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 100,
              child: _dataCell(
                (item['Replacement Layer 1'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 100,
              child: _dataCell(
                (item['Replacement Layer 2'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 100,
              child: _dataCell(
                (item['Replacement Layer 3'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 100,
              child: _dataCell(
                (item['Replacement Layer 4'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(
              width: 100,
              child: _dataCell(
                (item['Replacement Hole'] ?? 0).toString(),
                textAlign: TextAlign.end,
              ),
            ),
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
            SizedBox(width: 60, child: _skeletonCell()),
            SizedBox(width: 160, child: _skeletonCell()),
            SizedBox(width: 140, child: _skeletonCell()),
            SizedBox(width: 100, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 80, child: _skeletonCell()),
            SizedBox(width: 100, child: _skeletonCell()),
            SizedBox(width: 100, child: _skeletonCell()),
            SizedBox(width: 100, child: _skeletonCell()),
            SizedBox(width: 100, child: _skeletonCell()),
            SizedBox(width: 100, child: _skeletonCell()),
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
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
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

  Widget _buildSummarySection(int totalItems, int totalOrder) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return Row(
      children: [
        Expanded(child: _buildSummaryCard("Total SKUs", totalItems.toString(), Icons.list_alt_outlined, const Color(0xFF334155))),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard("Total Order", numberFormat.format(totalOrder), Icons.shopping_cart_outlined, const Color(0xFFBE123C))),
      ],
    );
  }

  Widget _buildTableContainer() {
    if (_rejectData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _rejectData!;
    final numberFormat = NumberFormat("#,##0", "en_US");

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
              color: const Color(0xFFEC4899).withOpacity(0.08),
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
                          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "NG & Replacement Data",
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
                    constraints: const BoxConstraints(minWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTableHeader(),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                        if (items.isEmpty)
                          _buildEmptyPlaceholder('Tidak ada data NG & Replacement tersedia.')
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
      ),
    );
  }

  Widget _buildDashboardView() {
    if (_rejectData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _rejectData!;
    final totalItems = items.length;
    final totalOrder = items.fold<int>(0, (sum, item) => sum + ((item['quantityOrder'] ?? 0) as num).toInt());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(totalItems, totalOrder),
          const SizedBox(height: 24),
          _buildTableContainer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "NG & Replacement",
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
                Color(0xFFEC4899),
                Color(0xFFDB2777),
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
                    Icon(Icons.share_outlined, color: Color(0xFFEC4899)),
                    SizedBox(width: 12),
                    Text("Bagikan Gambar"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, color: Color(0xFFDB2777)),
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
      body: Stack(
        children: [
          // ✅ UI utama — gunakan state langsung
          _buildDashboardView(),

          // ✅ Offscreen widget — SELALU ada, gunakan data state
          Offstage(
            offstage: true,
            child: RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                width: 1300, // Lebar cukup untuk semua kolom NG & Replacement
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTableHeader(),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    if (_rejectData == null)
                      const SizedBox.shrink()
                    else if (_rejectData!.isEmpty)
                      _buildEmptyPlaceholder('Tidak ada data NG & Replacement tersedia.')
                    else
                      ..._rejectData!.map((item) => _buildTableRow(item, NumberFormat("#,##0", "en_US"))).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}