// lib/screens/departments/bonding/reject/input_reject_bonding_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinus_production/repositories/master_data/master_data_repository.dart';
import 'package:zinus_production/repositories/departments/bonding_repository.dart';

class InputRejectBondingScreen extends StatefulWidget {
  const InputRejectBondingScreen({super.key});

  @override
  State<InputRejectBondingScreen> createState() =>
      _InputRejectBondingScreenState();
}

class _InputRejectBondingScreenState extends State<InputRejectBondingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _repo = MasterDataRepository();
  final _ngQuantityController = TextEditingController();
  final _reasonController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // === HEADER ===
  late DateTime _timestamp;
  String? _selectedShift = '1';
  String? _selectedGroup = 'A';
  String? _selectedTime;
  String? _selectedMachine;

  // === KASHIFT & ADMIN ===
  String? _kashift;
  String? _admin;

  // === MASTER DATA ===
  String? _selectedCustomer;
  String? _selectedCustomerLabel;
  String? _selectedPoNumber;
  String? _selectedCustomerPo;
  String? _selectedSku;

  // === S.CODE (baru) ===
  String? _selectedSCode;
  String? _sCodeDescription;

  // === LOADING STATES ===
  bool _loadingCustomers = false;
  bool _loadingPoNumbers = false;
  bool _loadingCustomerPos = false;
  bool _loadingSkus = false;
  bool _loadingSCodes = false;
  bool _isSubmitting = false;

  // === DATA LIST ===
  List<dynamic> _customers = [];
  List<dynamic> _poNumbers = [];
  List<dynamic> _customerPos = [];
  List<dynamic> _skus = [];
  List<dynamic> _sCodes = [];

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();
    _selectedTime = _getTimeSlots('1').first;
    _updateKashiftAdmin(_selectedGroup);
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
    _ngQuantityController.dispose();
    _reasonController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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
          _sCodes = [];
          _selectedPoNumber = null;
          _selectedCustomerPo = null;
          _selectedSku = null;
          _selectedSCode = null;
          _sCodeDescription = null;
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
          _sCodes = [];
          _selectedCustomerPo = null;
          _selectedSku = null;
          _selectedSCode = null;
          _sCodeDescription = null;
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
          _sCodes = [];
          _selectedSku = null;
          _selectedSCode = null;
          _sCodeDescription = null;
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

  Future<void> _loadSCodes(String customerPo, String sku) async {
    setState(() => _loadingSCodes = true);
    try {
      final qtyPlansData = await _repo.getQtyPlans(customerPo, sku);
      List<dynamic> sCodeList = [];

      if (qtyPlansData.isNotEmpty) {
        final firstPlan = qtyPlansData[0] as Map<String, dynamic>;
        final sCodesRaw = firstPlan['s_codes'] as List<dynamic>?;
        if (sCodesRaw != null) {
          sCodeList = sCodesRaw.map((sc) {
            final sCodeMap = sc as Map<String, dynamic>;
            return {
              'value': sCodeMap['s_code'].toString(),
              'label': sCodeMap['s_code'].toString(),
              'description': sCodeMap['description']?.toString() ?? '',
            };
          }).toList();
        }
      }

      if (mounted) {
        setState(() {
          _sCodes = sCodeList;
          _selectedSCode = null;
          _sCodeDescription = null;
          _loadingSCodes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSCodes = false);
        _showError('Gagal memuat S.CODE');
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_selectedCustomer == null ||
        _selectedCustomerLabel == null ||
        _selectedPoNumber == null ||
        _selectedCustomerPo == null ||
        _selectedSku == null ||
        _selectedSCode == null ||
        _selectedShift == null ||
        _selectedGroup == null ||
        _selectedTime == null ||
        _selectedMachine == null ||
        _kashift == null ||
        _admin == null) {
      _showError('Lengkapi semua field yang diperlukan');
      return;
    }

    final ngQty = int.tryParse(_ngQuantityController.text);
    if (ngQty == null || ngQty <= 0) {
      _showError('Quantity NG harus > 0');
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      _showError('Alasan NG wajib diisi');
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
      'customer': _selectedCustomerLabel,
      'po_number': _selectedPoNumber,
      'customer_po': _selectedCustomerPo,
      'sku': _selectedSku,
      's_code': _selectedSCode,
      'ng_quantity': ngQty,
      'reason': reason,
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await BondingRepository.submitRejectFormInput(formData);
      if (mounted) {
        _showSuccess('Data NG berhasil disimpan!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception:', '').trim()
            : 'Gagal menyimpan data NG';
        _showError(msg);
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

  // === BUILDERS ===
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBE123C), Color(0xFFDC2626)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.3),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
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
                  color: const Color(0xFFDC2626).withOpacity(0.08),
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
                        child: Icon(
                          icon,
                          color: enabled ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                          size: 22,
                        ),
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
                color: enabled ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                size: 28,
              ),
              hint: Text(
                enabled ? 'Pilih...' : 'Pilih data sebelumnya',
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
    final displayColor = accentColor ?? const Color(0xFFDC2626);
    
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
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
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
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
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
                    child: Icon(icon, color: const Color(0xFFDC2626), size: 22),
                  )
                : null,
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          keyboardType: TextInputType.text,
          validator: validator,
          maxLines: label.toLowerCase().contains('alasan') ? 3 : 1,
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
          'Input Reject Bonding',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: Color(0xFFBE123C),
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
                  const Color(0xFFDC2626).withOpacity(0.1),
                  const Color(0xFFDC2626).withOpacity(0.3),
                  const Color(0xFFDC2626).withOpacity(0.1),
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
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFDC2626).withOpacity(0.08),
                            const Color(0xFFBE123C).withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFDC2626).withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withOpacity(0.15),
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
                              color: const Color(0xFFDC2626).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.access_time_rounded,
                                color: Color(0xFFDC2626), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm:ss').format(_timestamp),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Shift, Group, Time, Machine
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
                      _updateKashiftAdmin(val);
                    });
                  },
                  icon: Icons.group_rounded,
                ),
                _buildLabeledDropdown(
                  label: 'Time',
                  value: _selectedTime,
                  options: _getTimeSlots(_selectedShift ?? '1')
                      .map((slot) => {'value': slot, 'label': slot})
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTime = val),
                  icon: Icons.timer_outlined,
                ),
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

                // Kashift & Admin
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

                // ✅ Perbaikan: Hapus `const` agar tidak error
                Divider(
                  height: 32,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),

                // Form Information
                _buildSectionHeader('Form Information', Icons.description_outlined),

                _buildLabeledDropdown(
                  label: 'Customer',
                  value: _selectedCustomer,
                  options: List<Map<String, dynamic>>.from(_customers),
                  onChanged: (val) {
                    setState(() {
                      _selectedCustomer = val;
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
                _buildLabeledDropdown(
                  label: 'SKU',
                  value: _selectedSku,
                  options: List<Map<String, dynamic>>.from(_skus),
                  enabled: _selectedCustomerPo != null,
                  onChanged: (val) {
                    setState(() => _selectedSku = val);
                    if (val != null && _selectedCustomerPo != null) {
                      _loadSCodes(_selectedCustomerPo!, val);
                    }
                  },
                  showLoading: _loadingSkus,
                  icon: Icons.inventory_2_rounded,
                ),
                _buildLabeledDropdown(
                  label: 'S.CODE',
                  value: _selectedSCode,
                  options: List<Map<String, dynamic>>.from(_sCodes),
                  enabled: _selectedSku != null,
                  onChanged: (val) {
                    setState(() {
                      _selectedSCode = val;
                      final selected = _sCodes.firstWhere(
                        (sc) => sc['value'].toString() == val,
                        orElse: () => {'description': ''},
                      );
                      _sCodeDescription = selected['description']?.toString();
                    });
                  },
                  showLoading: _loadingSCodes,
                  icon: Icons.code_rounded,
                ),
                _buildLabeledDisplay(
                  label: 'Description',
                  value: _sCodeDescription ?? '-',
                  icon: Icons.description_rounded,
                  accentColor: const Color(0xFF7C2D12),
                ),
                _buildLabeledTextField(
                  label: 'Quantity NG',
                  controller: _ngQuantityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Wajib diisi';
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) return 'Masukkan angka > 0';
                    return null;
                  },
                  icon: Icons.production_quantity_limits_rounded,
                ),
                _buildLabeledTextField(
                  label: 'Alasan NG',
                  controller: _reasonController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alasan wajib diisi';
                    }
                    return null;
                  },
                  icon: Icons.report_gmailerrorred_rounded,
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
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
                      _isSubmitting ? 'Menyimpan...' : 'Simpan Data NG',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitting
                          ? const Color(0xFFBE123C).withOpacity(0.7)
                          : const Color(0xFFBE123C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFDC2626).withOpacity(0.4),
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