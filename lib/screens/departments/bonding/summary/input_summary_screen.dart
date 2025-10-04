// lib/screens/departments/bonding/summary/input_summary_screen.dart
import 'package:flutter/material.dart';

class InputSummaryScreen extends StatefulWidget {
  const InputSummaryScreen({super.key});

  @override
  State<InputSummaryScreen> createState() => _InputSummaryScreenState();
}

class _InputSummaryScreenState extends State<InputSummaryScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late AnimationController _saveAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // --- State Variables ---
  late String _date;
  String? _shift;
  String? _operatorName;
  String? _machine;
  String? _timeSlot;
  String? _buyerId;
  String? _poNumber;
  String? _skuId;
  String? _status;
  String? _keterangan;
  String? _qty;
  String? _group;

  bool _isLoading = false;

  // --- Dummy Data ---
  final List<String> _operators = ['Andi', 'Budi', 'Citra', 'Dewi', 'Eko'];
  final List<String> _machines = ['Machine 1', 'Machine 2', 'Machine 3', 'Machine 4'];
  final List<String> _groups = ['A', 'B'];
  final List<String> _statuses = ['RESIZE', 'KEEPING'];

  // --- Generate Time Slots ---
  static List<String> _generateTimeSlots() {
    List<String> slots = [];
    int startHour = 19;
    int startMinute = 0;

    for (int i = 0; i < 13; i++) {
      String startTime =
          "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";

      int endHour = startHour + 1;
      int endMinute = startMinute;
      if (endHour >= 24) {
        endHour -= 24;
      }
      String endTime =
          "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";

      slots.add("$startTime - $endTime");

      startHour = endHour;
      startMinute = endMinute;
    }
    return slots;
  }

  final List<String> _timeSlots = _generateTimeSlots();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now().toIso8601String().split('T').first;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    _saveAnimationController.forward();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1200));

      // bool isSuccess = await ApiService.insertBondingSummaryEntry(entry);
      // For now, we'll assume the save is always successful
      const bool isSuccess = true;


      if (mounted) {
        if (isSuccess) {
          _showSuccessDialog();
          _resetForm();
        } else {
          _showErrorDialog("Failed to save data. (Simulated error)");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _saveAnimationController.reset();
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _shift = null;
      _operatorName = null;
      _machine = null;
      _timeSlot = null;
      _buyerId = null;
      _poNumber = null;
      _skuId = null;
      _status = null;
      _keterangan = null;
      _qty = null;
      _group = null;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Data Tersimpan!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Summary data berhasil disimpan (simulasi).",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Color(0xFFEF4444),
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Gagal Menyimpan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Error: $error",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF59E0B),
                      Color(0xFFD97706),
                      Color(0xFFB45309),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BackgroundPatternPainter(),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Input Summary Data",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Bonding Department",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Production Date",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(_date),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        const Text(
                          "Production Details",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Fill in all required information",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Shift & Operator Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumDropdown(
                                value: _shift,
                                label: "Shift",
                                icon: Icons.schedule_rounded,
                                items: ['shift 1', 'shift 2']
                                    .map((shift) => DropdownMenuItem(
                                          value: shift,
                                          child: Text(shift.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _shift = value),
                                validator: (value) =>
                                    value == null ? "Pilih shift" : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumDropdown(
                                value: _operatorName,
                                label: "Operator",
                                icon: Icons.person_rounded,
                                items: _operators
                                    .map((name) => DropdownMenuItem(
                                          value: name,
                                          child: Text(name),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _operatorName = value),
                                validator: (value) =>
                                    value == null ? "Pilih operator" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Machine & Time Slot Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumDropdown(
                                value: _machine,
                                label: "Machine",
                                icon: Icons.precision_manufacturing_rounded,
                                items: _machines
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _machine = value),
                                validator: (value) =>
                                    value == null ? "Pilih machine" : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumDropdown(
                                value: _timeSlot,
                                label: "Time Slot",
                                icon: Icons.access_time_rounded,
                                items: _timeSlots
                                    .map((slot) => DropdownMenuItem(
                                          value: slot,
                                          child: Text(slot),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _timeSlot = value),
                                validator: (value) =>
                                    value == null ? "Pilih jam" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Buyer ID & PO Number Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildPremiumTextField(
                                value: _buyerId,
                                label: "Buyer ID",
                                icon: Icons.business_rounded,
                                onChanged: (value) =>
                                    setState(() => _buyerId = value),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? "Masukkan Buyer ID" : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumTextField(
                                value: _poNumber,
                                label: "PO Number",
                                icon: Icons.receipt_long_rounded,
                                onChanged: (value) =>
                                    setState(() => _poNumber = value),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? "Masukkan PO Number" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // SKU ID & Status Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildPremiumTextField(
                                value: _skuId,
                                label: "SKU ID",
                                icon: Icons.inventory_2_rounded,
                                onChanged: (value) =>
                                    setState(() => _skuId = value),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? "Masukkan SKU ID" : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumDropdown(
                                value: _status,
                                label: "Status",
                                icon: Icons.flag_rounded,
                                items: _statuses
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _status = value),
                                validator: (value) =>
                                    value == null ? "Pilih status" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Keterangan & Qty Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildPremiumTextField(
                                value: _keterangan,
                                label: "Keterangan",
                                icon: Icons.note_rounded,
                                onChanged: (value) =>
                                    setState(() => _keterangan = value),
                                validator: (value) => value?.isEmpty ?? true
                                    ? "Masukkan keterangan"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPremiumTextField(
                                value: _qty,
                                label: "Quantity",
                                icon: Icons.numbers_rounded,
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>
                                    setState(() => _qty = value),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return "Masukkan qty";
                                  if (int.tryParse(value!) == null)
                                    return "Qty harus angka";
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Group
                        _buildPremiumDropdown(
                          value: _group,
                          label: "Group",
                          icon: Icons.group_work_rounded,
                          items: _groups
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text("Group $g"),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _group = value),
                          validator: (value) =>
                              value == null ? "Pilih group" : null,
                        ),
                        const SizedBox(height: 40),

                        // Save Button
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFF59E0B).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : _saveEntry,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isLoading) ...[
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Text(
                                          "MENYIMPAN...",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Text(
                                          "SIMPAN SUMMARY",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return Container(
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
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFF59E0B),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required String? value,
    required String label,
    required IconData icon,
    required void Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
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
      child: TextFormField(
        initialValue: value,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF59E0B),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFF59E0B),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
  }
}

/// Custom painter untuk background pattern
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      25,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
