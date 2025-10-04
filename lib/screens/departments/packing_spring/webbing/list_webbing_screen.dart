
import 'package:flutter/material.dart';
import 'dart:async';

class ListWebbingScreen extends StatefulWidget {
  const ListWebbingScreen({super.key});

  @override
  State<ListWebbingScreen> createState() => _ListWebbingScreenState();
}

class _ListWebbingScreenState extends State<ListWebbingScreen> {
  late Future<List<Map<String, String>>> _webbingEntriesFuture;

  // --- Data Simulasi ---
  final List<Map<String, String>> _dummyEntries = [
    {
      "skuId": "SKU-XYZ-1",
      "webbingGroup": "A",
      "buyerId": "Buyer A",
      "poNumber": "PO-001A",
      "date": "2023-10-27",
      "shift": "shift 1",
      "operatorName": "Andi",
      "machine": "Machine 1",
      "timeSlot": "19:00 - 20:00",
    },
    {
      "skuId": "SKU-ABC-3",
      "webbingGroup": "B",
      "buyerId": "Buyer B",
      "poNumber": "PO-003B",
      "date": "2023-10-27",
      "shift": "shift 1",
      "operatorName": "Budi",
      "machine": "Machine 2",
      "timeSlot": "20:00 - 21:00",
    },
    {
      "skuId": "SKU-DEF-5",
      "webbingGroup": "A",
      "buyerId": "Buyer C",
      "poNumber": "PO-005C",
      "date": "2023-10-27",
      "shift": "shift 2",
      "operatorName": "Citra",
      "machine": "Machine 1",
      "timeSlot": "21:00 - 22:00",
    },
  ];

  // --- Fungsi Simulasi untuk Mengambil Data ---
  Future<List<Map<String, String>>> _getSimulatedEntries() async {
    // Simulasi jeda jaringan
    await Future.delayed(const Duration(seconds: 1));
    return _dummyEntries;
  }

  @override
  void initState() {
    super.initState();
    _webbingEntriesFuture = _getSimulatedEntries();
  }

  Future<void> _refreshData() async {
    setState(() {
      _webbingEntriesFuture = _getSimulatedEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Webbing Entries (Simulation)'),
        backgroundColor: const Color(0xFF047857),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _webbingEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data.'));
          } else {
            final entries = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${entry['skuId']} - Group ${entry['webbingGroup']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.business_rounded, "Buyer", entry['buyerId'] ?? 'N/A'),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.receipt_long_rounded, "PO No", entry['poNumber'] ?? 'N/A'),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                           _buildInfoRow(Icons.person_rounded, "Operator", entry['operatorName'] ?? 'N/A'),
                           const SizedBox(height: 4),
                          _buildInfoRow(Icons.precision_manufacturing_rounded, "Machine", entry['machine'] ?? 'N/A'),
                           const SizedBox(height: 4),
                          _buildInfoRow(Icons.schedule_rounded, "Shift", entry['shift'] ?? 'N/A'),
                           const SizedBox(height: 4),
                          _buildInfoRow(Icons.access_time_rounded, "Time", "${entry['date']} | ${entry['timeSlot']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 16),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
