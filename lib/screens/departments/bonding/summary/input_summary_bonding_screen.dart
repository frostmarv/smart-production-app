// lib/screens/departments/bonding/summary/input_summary_bonding_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/master_data/master_data_repository.dart';

class InputSummaryBondingScreen extends StatefulWidget {
  const InputSummaryBondingScreen({super.key});

  @override
  State<InputSummaryBondingScreen> createState() =>
      _InputSummaryBondingScreenState();
}

class _InputSummaryBondingScreenState extends State<InputSummaryBondingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = MasterDataRepository();
  final _qtyProduksiController = TextEditingController();

  // === HEADER ===
  late DateTime _timestamp;
  String? _selectedShift = '1';
  String? _selectedGroup = 'A';
  String? _selectedTime;
  String? _selectedMachine;
  String? _selectedOperator;

  // === MASTER DATA (ENTRY TUNGGAL) ===
  String? _selectedCustomer;
  String? _selectedPoNumber;
  String? _selectedCustomerPo;
  String? _selectedSku;

  // === AUTO-FILLED DATA ===
  int? _quantityOrder;
  int? _remainQuantity;
  int? _progress; // 👈 TAMBAHKAN INI
  String? _week;

  // === LOADING STATES ===
  bool _loadingCustomers = false;
  bool _loadingPoNumbers = false;
  bool _loadingCustomerPos = false;
  bool _loadingSkus = false;
  bool _loadingWeeks = false;

  // === DATA LIST ===
  List<dynamic> _customers = [];
  List<dynamic> _poNumbers = [];
  List<dynamic> _customerPos = [];
  List<dynamic> _skus = [];

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();
    _selectedTime = _getTimeSlots('1').first;
    _loadCustomers();
  }

  @override
  void dispose() {
    _qtyProduksiController.dispose();
    super.dispose();
  }

  // === TIME SLOTS ===
  List<String> _getTimeSlots(String shift) {
    if (shift == '1') {
      return List.generate(12, (i) {
        final start = 8 + i;
        final end = start + 1;
        return '${start.toString().padLeft(2, '0')}.00 - ${end.toString().padLeft(2, '0')}.00';
      });
    } else {
      final slots = <String>[];
      for (int i = 20; i < 24; i++) {
        slots.add('${i.toString().padLeft(2, '0')}.00 - ${(i + 1).toString().padLeft(2, '0')}.00');
      }
      for (int i = 0; i < 8; i++) {
        slots.add('${i.toString().padLeft(2, '0')}.00 - ${(i + 1).toString().padLeft(2, '0')}.00');
      }
      return slots;
    }
  }

  // === API CALLS ===
  Future<void> _loadCustomers() async {
    setState(() => _loadingCustomers = true);
    try {
      final data = await _repo.getCustomers();
      if (mounted) {
        setState(() {
          _customers = data;
          _loadingCustomers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCustomers = false);
        _showError('Gagal memuat customer');
      }
    }
  }

  Future<void> _loadPoNumbers(String customerId) async {
    setState(() => _loadingPoNumbers = true);
    try {
      final data = await _repo.getPoNumbers(customerId);
      if (mounted) {
        setState(() {
          _poNumbers = data;
          _customerPos = [];
          _skus = [];
          _selectedPoNumber = null;
          _selectedCustomerPo = null;
          _selectedSku = null;
          _quantityOrder = null;
          _remainQuantity = null;
          _progress = null; // 👈 reset
          _week = null;
          _loadingPoNumbers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPoNumbers = false);
        _showError('Gagal memuat PO Numbers');
      }
    }
  }

  Future<void> _loadCustomerPos(String poNumber) async {
    setState(() => _loadingCustomerPos = true);
    try {
      final data = await _repo.getCustomerPOs(poNumber);
      if (mounted) {
        setState(() {
          _customerPos = data;
          _skus = [];
          _selectedCustomerPo = null;
          _selectedSku = null;
          _quantityOrder = null;
          _remainQuantity = null;
          _progress = null; // 👈 reset
          _week = null;
          _loadingCustomerPos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCustomerPos = false);
        _showError('Gagal memuat Customer POs');
      }
    }
  }

  Future<void> _loadSkus(String customerPo) async {
    setState(() => _loadingSkus = true);
    try {
      final data = await _repo.getSkus(customerPo);
      if (mounted) {
        setState(() {
          _skus = data;
          _selectedSku = null;
          _quantityOrder = null;
          _remainQuantity = null;
          _progress = null; // 👈 reset
          _week = null;
          _loadingSkus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSkus = false);
        _showError('Gagal memuat SKUs');
      }
    }
  }

  Future<void> _loadWeeksAndQty(String customerPo, String sku) async {
    setState(() => _loadingWeeks = true);
    try {
      final weeksData = await _repo.getWeeks(customerPo, sku);
      String? weekValue;
      int? progressValue;

      if (weeksData.isNotEmpty) {
        final firstWeek = weeksData[0] as Map<String, dynamic>;
        weekValue = firstWeek['value'] as String?;

        // Coba ambil progress dari weeksData
        progressValue = firstWeek['progress'] as int?;

        final sCodes = firstWeek['s_codes'] as List?;
        if (sCodes != null && sCodes.isNotEmpty) {
          final firstSCode = sCodes[0] as Map<String, dynamic>;
          final sCode = firstSCode['s_code'] as String?;
          if (sCode != null) {
            final remainData = await _repo.getRemainQuantity(customerPo, sku, sCode);
            // Jika belum dapat progress, coba dari remainData
            progressValue ??= remainData['progress'] as int?;
            setState(() {
              _remainQuantity = remainData['remainQuantity'] as int?;
              _quantityOrder = remainData['quantityOrder'] as int?;
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _week = weekValue;
          _progress = progressValue;
          _loadingWeeks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingWeeks = false);
        _showError('Gagal memuat data Week/Quantity');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // === BUILDERS ===
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildLabeledDropdown({
    required String label,
    String? value,
    required List<Map<String, dynamic>> options,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
    bool showLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (showLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: Colors.blue,
            backgroundColor: Colors.grey,
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                isDense: true,
              ),
              value: value,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option['value'].toString(),
                  child: Text(option['label'].toString()),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              hint: enabled
                  ? const Text('Pilih...')
                  : const Text('Pilih data sebelumnya terlebih dahulu',
                      style: TextStyle(color: Colors.grey)),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabeledDisplay({
    required String label,
    required String? value,
    bool loading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: loading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Text(
                  value ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            prefixIcon: const Icon(Icons.production_quantity_limits_outlined,
                color: Colors.blue),
          ),
          keyboardType: TextInputType.number,
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Input Summary Bonding'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER SECTION ===
              _buildSectionHeader('Header Information'),

              // Timestamp
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Timestamp',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy, HH:mm:ss')
                          .format(_timestamp),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Shift
              _buildLabeledDropdown(
                label: 'Shift',
                value: _selectedShift,
                options: const [
                  {'value': '1', 'label': '1'},
                  {'value': '2', 'label': '2'},
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedShift = val;
                    _selectedTime = _getTimeSlots(val ?? '1').first;
                  });
                },
              ),

              // Group
              _buildLabeledDropdown(
                label: 'Group',
                value: _selectedGroup,
                options: const [
                  {'value': 'A', 'label': 'A'},
                  {'value': 'B', 'label': 'B'},
                ],
                onChanged: (val) => setState(() => _selectedGroup = val),
              ),

              // Time
              _buildLabeledDropdown(
                label: 'Time',
                value: _selectedTime,
                options: _getTimeSlots(_selectedShift ?? '1')
                    .map((slot) => {'value': slot, 'label': slot})
                    .toList(),
                onChanged: (val) => setState(() => _selectedTime = val),
              ),

              // Machine
              _buildLabeledDropdown(
                label: 'Machine',
                value: _selectedMachine,
                options: List.generate(
                  8,
                  (i) => {
                    'value': 'PUR ${i + 1}',
                    'label': 'PUR ${i + 1}',
                  },
                ),
                onChanged: (val) => setState(() => _selectedMachine = val),
              ),

              // Operator
              _buildLabeledDropdown(
                label: 'Operator',
                value: _selectedOperator,
                options: const [
                  {'value': 'Andi', 'label': 'Andi'},
                  {'value': 'Budi', 'label': 'Budi'},
                ],
                onChanged: (val) => setState(() => _selectedOperator = val),
              ),

              const Divider(height: 32, thickness: 1, color: Colors.grey),

              // === MASTER DATA SECTION ===
              _buildSectionHeader('Form Information'),

              // Customer
              _buildLabeledDropdown(
                label: 'Customer',
                value: _selectedCustomer,
                options: List<Map<String, dynamic>>.from(_customers),
                onChanged: (val) {
                  setState(() => _selectedCustomer = val);
                  if (val != null) _loadPoNumbers(val);
                },
                showLoading: _loadingCustomers,
              ),

              // PO Number
              _buildLabeledDropdown(
                label: 'PO Number',
                value: _selectedPoNumber,
                options: List<Map<String, dynamic>>.from(_poNumbers),
                enabled: _selectedCustomer != null,
                onChanged: (val) {
                  setState(() => _selectedPoNumber = val);
                  if (val != null) _loadCustomerPos(val);
                },
                showLoading: _loadingPoNumbers,
              ),

              // Customer PO
              _buildLabeledDropdown(
                label: 'Customer PO',
                value: _selectedCustomerPo,
                options: List<Map<String, dynamic>>.from(_customerPos),
                enabled: _selectedPoNumber != null,
                onChanged: (val) {
                  setState(() => _selectedCustomerPo = val);
                  if (val != null) _loadSkus(val);
                },
                showLoading: _loadingCustomerPos,
              ),

              // SKU
              _buildLabeledDropdown(
                label: 'SKU',
                value: _selectedSku,
                options: List<Map<String, dynamic>>.from(_skus),
                enabled: _selectedCustomerPo != null,
                onChanged: (val) {
                  setState(() => _selectedSku = val);
                  if (val != null && _selectedCustomerPo != null) {
                    _loadWeeksAndQty(_selectedCustomerPo!, val);
                  }
                },
                showLoading: _loadingSkus,
              ),

              // Quantity Order
              _buildLabeledDisplay(
                label: 'Quantity Order',
                value: _quantityOrder?.toString(),
                loading: _loadingWeeks,
              ),

              // Progress ← BARU DITAMBAHKAN
              _buildLabeledDisplay(
                label: 'Progress',
                value: _progress?.toString() ?? '0',
                loading: _loadingWeeks,
              ),

              // Quantity Produksi
              _buildLabeledTextField(
                label: 'Quantity Produksi',
                controller: _qtyProduksiController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib diisi';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Masukkan angka > 0';
                  }
                  return null;
                },
              ),

              // Remain Quantity
              _buildLabeledDisplay(
                label: 'Remain Quantity',
                value: _remainQuantity?.toString(),
                loading: _loadingWeeks,
              ),

              // Week
              _buildLabeledDisplay(
                label: 'Week',
                value: _week,
                loading: _loadingWeeks,
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      // TODO: Submit logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data berhasil disimpan!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Simpan Data', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}