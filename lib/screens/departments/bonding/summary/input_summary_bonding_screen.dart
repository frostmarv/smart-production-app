// lib/screens/departments/bonding/summary/input_summary_bonding_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/master_data/master_data_repository.dart';
import 'package:zinus_production/repositories/departments/bonding_repository.dart'; // <-- Tambahkan ini

class InputSummaryBondingScreen extends StatefulWidget {
  const InputSummaryBondingScreen({super.key});

  @override
  State<InputSummaryBondingScreen> createState() =>
      _InputSummaryBondingScreenState();
}

class _InputSummaryBondingScreenState extends State<InputSummaryBondingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _repo = MasterDataRepository();
  final _qtyProduksiController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // === HEADER ===
  late DateTime _timestamp;
  String? _selectedShift = '1';
  String? _selectedGroup = 'A';
  String? _selectedTime;
  String? _selectedMachine;
  // String? _selectedOperator; // ❌ Dihapus

  // === KASHIFT & ADMIN (baru) ===
  String? _kashift;
  String? _admin;

  // === MASTER DATA (ENTRY TUNGGAL) ===
  String? _selectedCustomer; // Stores VALUE (ID) for API calls
  String? _selectedCustomerLabel; // Stores LABEL for backend submission
  String? _selectedPoNumber;
  String? _selectedCustomerPo;
  String? _selectedSku;

  // === AUTO-FILLED DATA ===
  int? _quantityOrder;
  int? _remainQuantity;
  // int? _progress; // ❌ Dihapus
  String? _week;

  // === LOADING STATES ===
  bool _loadingCustomers = false;
  bool _loadingPoNumbers = false;
  bool _loadingCustomerPos = false;
  bool _loadingSkus = false;
  bool _loadingData = false;
  bool _isSubmitting = false; // ✅ Untuk loading saat submit

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
    _updateKashiftAdmin(_selectedGroup); // Set awal
    _loadCustomers();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  // ✅ Helper untuk update Kashift & Admin berdasarkan Group
  void _updateKashiftAdmin(String? group) {
    if (group == 'A') {
      _kashift = 'Noval';
      _admin = 'Aline';
    } else if (group == 'B') {
      _kashift = 'Abizar';
      _admin = 'Puji';
    } else {
      _kashift = null;
      _admin = null;
    }
  }

  @override
  void dispose() {
    _qtyProduksiController.dispose();
    _animationController.dispose();
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
        slots.add(
            '${i.toString().padLeft(2, '0')}.00 - ${(i + 1).toString().padLeft(2, '0')}.00');
      }
      for (int i = 0; i < 8; i++) {
        slots.add(
            '${i.toString().padLeft(2, '0')}.00 - ${(i + 1).toString().padLeft(2, '0')}.00');
      }
      return slots;
    }
  }

  // === API CALLS (tidak berubah kecuali penyesuaian minor) ===
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
          // _progress = null; // Dihapus
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
          // _progress = null;
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
          // _progress = null;
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

  Future<void> _loadAllData(String customerPo, String sku) async {
    setState(() => _loadingData = true);
    try {
      final qtyPlansData = await _repo.getQtyPlans(customerPo, sku);
      int? qtyOrder;
      List<dynamic>? sCodesList;

      if (qtyPlansData.isNotEmpty) {
        final firstPlan = qtyPlansData[0] as Map<String, dynamic>;
        final qtyValue = firstPlan['value'];
        qtyOrder = qtyValue is int ? qtyValue : int.tryParse(qtyValue.toString());
        sCodesList = firstPlan['s_codes'] as List<dynamic>?;
      }

      final weeksData = await _repo.getWeeks(customerPo, sku);
      String? weekValue;
      if (weeksData.isNotEmpty) {
        final firstWeek = weeksData[0] as Map<String, dynamic>;
        weekValue = firstWeek['value']?.toString();
      }

      int? remainQty;
      // int? progressValue; // Tidak dipakai

      if (sCodesList != null && sCodesList.isNotEmpty) {
        final firstSCode = sCodesList[0] as Map<String, dynamic>;
        final sCode = firstSCode['s_code']?.toString();
        if (sCode != null) {
          final remainData =
              await _repo.getRemainQuantity(customerPo, sku, sCode);
          remainQty = remainData['remainQuantity'] is int
              ? remainData['remainQuantity'] as int
              : int.tryParse(remainData['remainQuantity'].toString());

          qtyOrder ??= remainData['quantityOrder'] is int
              ? remainData['quantityOrder'] as int
              : int.tryParse(remainData['quantityOrder'].toString());
        }
      }

      if (mounted) {
        setState(() {
          _quantityOrder = qtyOrder;
          _remainQuantity = remainQty;
          // _progress = progressValue;
          _week = weekValue;
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingData = false);
        _showError('Gagal memuat data master');
      }
    }
  }

  // ✅ Submit ke backend
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    // Pastikan semua data wajib terisi
    if (_selectedCustomer == null ||
        _selectedCustomerLabel == null ||
        _selectedPoNumber == null ||
        _selectedCustomerPo == null ||
        _selectedSku == null ||
        _selectedShift == null ||
        _selectedGroup == null ||
        _selectedTime == null ||
        _selectedMachine == null ||
        _kashift == null ||
        _admin == null ||
        _week == null) {
      _showError('Lengkapi semua field yang diperlukan');
      return;
    }

    final qtyProduksi = int.tryParse(_qtyProduksiController.text);
    if (qtyProduksi == null || qtyProduksi <= 0) {
      _showError('Quantity Produksi tidak valid');
      return;
    }

    final formData = {
      'timestamp': _timestamp.toIso8601String(),
      'shift': _selectedShift,
      'group': _selectedGroup,
      'time_slot': _selectedTime,
      'machine': _selectedMachine,
      'kashift': _kashift,
      'admin': _admin,
      'customer': _selectedCustomerLabel, // ✅ Send LABEL, not VALUE
      'po_number': _selectedPoNumber,
      'customer_po': _selectedCustomerPo,
      'sku': _selectedSku,
      'week': _week,
      'quantity_produksi': qtyProduksi,
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await BondingRepository.submitFormInput(formData);
      if (mounted) {
        _showSuccess('Data berhasil disimpan!');
        // Reset form after successful submit
        _qtyProduksiController.clear();
        // Optionally navigate back or refresh
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Show detailed error message
        final errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception:', '').trim()
            : 'Gagal menyimpan data: ${e.toString()}';
        _showError(errorMessage);
        print('❌ Submit error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // === PREMIUM BUILDERS (tidak berubah kecuali penyesuaian minor) ===
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (showLoading)
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                prefixIcon: icon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(icon,
                            color: enabled
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF94A3B8),
                            size: 22),
                      )
                    : null,
                isDense: true,
              ),
              value: value,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option['value'].toString(),
                  child: Text(
                    option['label'].toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                size: 28,
              ),
              hint: Text(
                enabled ? 'Pilih...' : 'Pilih data sebelumnya terlebih dahulu',
                style: TextStyle(
                  color: enabled ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLabeledDisplay({
    required String label,
    required String? value,
    bool loading = false,
    IconData? icon,
    Color? accentColor,
  }) {
    final displayColor = accentColor ?? const Color(0xFF3B82F6);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                displayColor.withOpacity(0.05),
                displayColor.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: displayColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: displayColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: displayColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: displayColor, size: 20),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      )
                    : Text(
                        value ?? '-',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: displayColor,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(icon, color: const Color(0xFF3B82F6), size: 22),
                  )
                : null,
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          keyboardType: TextInputType.number,
          validator: validator,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Input Summary Bonding',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF3B82F6).withOpacity(0.3),
                  const Color(0xFF3B82F6).withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER SECTION ===
                _buildSectionHeader('Header Information', Icons.info_outline_rounded),

                // Timestamp
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Timestamp',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5CF6).withOpacity(0.08),
                            const Color(0xFF6366F1).withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.access_time_rounded,
                                color: Color(0xFF8B5CF6), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm:ss').format(_timestamp),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5CF6),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
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
                  icon: Icons.schedule_rounded,
                ),

                // Group
                _buildLabeledDropdown(
                  label: 'Group',
                  value: _selectedGroup,
                  options: const [
                    {'value': 'A', 'label': 'A'},
                    {'value': 'B', 'label': 'B'},
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedGroup = val;
                      _updateKashiftAdmin(val); // ✅ Update Kashift & Admin
                    });
                  },
                  icon: Icons.group_rounded,
                ),

                // Time
                _buildLabeledDropdown(
                  label: 'Time',
                  value: _selectedTime,
                  options: _getTimeSlots(_selectedShift ?? '1')
                      .map((slot) => {'value': slot, 'label': slot})
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTime = val),
                  icon: Icons.timer_outlined,
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
                  icon: Icons.precision_manufacturing_rounded,
                ),

                // === KASHIFT & ADMIN (baru) ===
                if (_kashift != null && _admin != null) ...[
                  _buildLabeledDisplay(
                    label: 'Kashift',
                    value: _kashift,
                    icon: Icons.supervisor_account_rounded,
                    accentColor: const Color(0xFF7C3AED),
                  ),
                  _buildLabeledDisplay(
                    label: 'Admin',
                    value: _admin,
                    icon: Icons.admin_panel_settings_rounded,
                    accentColor: const Color(0xFFEC4899),
                  ),
                ],

                // === DIVIDER ===
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF94A3B8).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // === MASTER DATA SECTION ===
                _buildSectionHeader('Form Information', Icons.description_outlined),

                // Customer
                _buildLabeledDropdown(
                  label: 'Customer',
                  value: _selectedCustomer,
                  options: List<Map<String, dynamic>>.from(_customers),
                  onChanged: (val) {
                    setState(() {
                      _selectedCustomer = val;
                      // Store label for backend submission
                      _selectedCustomerLabel = _customers.firstWhere(
                        (c) => c['value'].toString() == val,
                        orElse: () => {'label': val},
                      )['label']?.toString();
                    });
                    if (val != null) _loadPoNumbers(val);
                  },
                  showLoading: _loadingCustomers,
                  icon: Icons.business_rounded,
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
                  icon: Icons.receipt_long_rounded,
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
                  icon: Icons.assignment_rounded,
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
                      _loadAllData(_selectedCustomerPo!, val);
                    }
                  },
                  showLoading: _loadingSkus,
                  icon: Icons.inventory_2_rounded,
                ),

                // Quantity Order
                _buildLabeledDisplay(
                  label: 'Quantity Order',
                  value: _quantityOrder?.toString() ?? '-',
                  loading: _loadingData,
                  icon: Icons.shopping_cart_rounded,
                  accentColor: const Color(0xFF059669),
                ),

                // ❌ Progress DIHAPUS

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
                  icon: Icons.production_quantity_limits_rounded,
                ),

                // Remain Quantity
                _buildLabeledDisplay(
                  label: 'Remain Quantity',
                  value: _remainQuantity?.toString() ?? '-',
                  loading: _loadingData,
                  icon: Icons.inventory_rounded,
                  accentColor: const Color(0xFFDC2626),
                ),

                // Week
                _buildLabeledDisplay(
                  label: 'Week',
                  value: _week ?? '-',
                  loading: _loadingData,
                  icon: Icons.calendar_today_rounded,
                  accentColor: const Color(0xFF8B5CF6),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm, // ✅ Nonaktifkan saat loading
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      _isSubmitting ? 'Menyimpan...' : 'Simpan Data',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitting
                          ? const Color(0xFF1E40AF).withOpacity(0.7)
                          : const Color(0xFF1E40AF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}