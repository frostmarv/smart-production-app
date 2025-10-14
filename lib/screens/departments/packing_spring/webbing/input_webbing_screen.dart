
import 'package:flutter/material.dart';

class InputWebbingScreen extends StatefulWidget {
  const InputWebbingScreen({super.key});

  @override
  State<InputWebbingScreen> createState() => _InputWebbingScreenState();
}

class _InputWebbingScreenState extends State<InputWebbingScreen>
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
  String? _group;

  // --- State untuk Master Data (Simulasi dengan String) ---
  String? _selectedBuyer;
  String? _selectedPo;
  String? _selectedSku;
  String? _selectedQty;

  bool _isLoading = false;

  // --- Dummy Data (Simulasi) ---
  final List<String> _operators = ['Andi', 'Budi', 'Citra', 'Dewi', 'Eko'];
  final List<String> _machines = ['Machine 1', 'Machine 2', 'Machine 3', 'Machine 4'];
  final List<String> _groups = ['A', 'B'];
  final List<String> _buyers = ['Buyer A', 'Buyer B', 'Buyer C'];
  final Map<String, List<String>> _posByBuyer = {
    'Buyer A': ['PO-001A', 'PO-002A'],
    'Buyer B': ['PO-003B'],
    'Buyer C': ['PO-004C', 'PO-005C'],
  };
  final Map<String, Map<String, String>> _skuByPo = {
    'PO-001A': {'sku': 'SKU-XYZ-1', 'qty': '100'},
    'PO-002A': {'sku': 'SKU-XYZ-2', 'qty': '200'},
    'PO-003B': {'sku': 'SKU-ABC-3', 'qty': '150'},
    'PO-004C': {'sku': 'SKU-DEF-4', 'qty': '300'},
    'PO-005C': {'sku': 'SKU-DEF-5', 'qty': '250'},
  };
  
  List<String> _currentPos = [];

  static List<String> _generateTimeSlots() {
    List<String> slots = [];
    int startHour = 19;
    int startMinute = 0;
    for (int i = 0; i < 13; i++) {
      String startTime = "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
      int endHour = startHour + 1;
      if (endHour >= 24) endHour -= 24;
      String endTime = "${endHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
      slots.add("$startTime - $endTime");
      startHour = endHour;
    }
    return slots;
  }

  final List<String> _timeSlots = _generateTimeSlots();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now().toIso8601String().split('T').first;

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _saveAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _saveAnimationController, curve: Curves.elasticOut));

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

    // --- Simulasi Simpan Data ---
    await Future.delayed(const Duration(milliseconds: 1500));
    // Tidak ada pembuatan object Entry, hanya simulasi berhasil
    
    setState(() => _isLoading = false);
    _saveAnimationController.reset();

    _showSuccessDialog();
    _resetForm();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _shift = null;
      _operatorName = null;
      _machine = null;
      _timeSlot = null;
      _selectedBuyer = null;
      _selectedPo = null;
      _selectedSku = null;
      _selectedQty = null;
      _group = null;
      _currentPos = [];
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
            Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 50)),
            const SizedBox(height: 24),
            const Text("Data Tersimpan!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),
            const Text("Data webbing berhasil disimulasikan.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
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
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false, pinned: true, elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))]), child: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B), size: 20), onPressed: () => Navigator.pop(context))),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)])),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _BackgroundPatternPainter())),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.web_asset_rounded, color: Colors.white, size: 24)),
                            const SizedBox(height: 12),
                            const Text("Input Webbing Data", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                            Text("Packing Spring Department", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                        _buildDateCard(),
                        const SizedBox(height: 32),
                        const Text("Production Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        const Text("Fill in all required information", style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        Row(children: [
                          Expanded(child: _buildPremiumDropdown<String>(value: _shift, label: "Shift", icon: Icons.schedule_rounded, items: ['shift 1', 'shift 2'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(), onChanged: (v) => setState(() => _shift = v), validator: (v) => v == null ? "Pilih shift" : null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPremiumDropdown<String>(value: _operatorName, label: "Operator", icon: Icons.person_rounded, items: _operators.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(), onChanged: (v) => setState(() => _operatorName = v), validator: (v) => v == null ? "Pilih operator" : null)),
                        ]),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: _buildPremiumDropdown<String>(value: _machine, label: "Machine", icon: Icons.precision_manufacturing_rounded, items: _machines.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _machine = v), validator: (v) => v == null ? "Pilih machine" : null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPremiumDropdown<String>(value: _timeSlot, label: "Time Slot", icon: Icons.access_time_rounded, items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _timeSlot = v), validator: (v) => v == null ? "Pilih jam" : null)),
                        ]),
                        const SizedBox(height: 20),
                        
                        // --- Buyer, PO, SKU (Simulasi) ---
                        _buildPremiumDropdown<String>(
                          value: _selectedBuyer,
                          label: "Buyer/Customer",
                          icon: Icons.business_rounded,
                          items: _buyers.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedBuyer = newValue;
                              _selectedPo = null;
                              _selectedSku = null;
                              _selectedQty = null;
                              _currentPos = newValue != null ? (_posByBuyer[newValue] ?? []) : [];
                            });
                          },
                          validator: (v) => v == null ? "Pilih buyer" : null,
                        ),
                        const SizedBox(height: 20),

                        if (_selectedBuyer != null)
                          _buildPremiumDropdown<String>(
                            value: _selectedPo,
                            label: "Customer PO",
                            icon: Icons.receipt_long_rounded,
                            items: _currentPos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedPo = newValue;
                                final skuData = newValue != null ? _skuByPo[newValue] : null;
                                _selectedSku = skuData?['sku'];
                                _selectedQty = skuData?['qty'];
                              });
                            },
                            validator: (v) => v == null ? "Pilih PO" : null,
                          ),
                        const SizedBox(height: 20),

                        Row(children: [
                          Expanded(flex: 2, child: _buildReadOnlyTextField("SKU", _selectedSku ?? "-")),
                          const SizedBox(width: 16),
                          Expanded(child: _buildReadOnlyTextField("Qty Order", _selectedQty ?? "-")),
                        ]),
                        const SizedBox(height: 20),
                        
                        _buildPremiumDropdown<String>(value: _group, label: "Group", icon: Icons.group_work_rounded, items: _groups.map((g) => DropdownMenuItem(value: g, child: Text("Group $g"))).toList(), onChanged: (v) => setState(() => _group = v), validator: (v) => v == null ? "Pilih group" : null),
                        const SizedBox(height: 40),

                        _buildSaveButton(),
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

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Production Date", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(_formatDate(_date), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  Widget _buildSaveButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity, height: 60,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _saveEntry,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_isLoading) ...[
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  const SizedBox(width: 16),
                  const Text("MENYIMPAN...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ] else ...[
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.save_rounded, color: Colors.white, size: 20)),
                  const SizedBox(width: 16),
                  const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumDropdown<T>({ required T? value, required String label, required IconData icon, required List<DropdownMenuItem<T>> items, required void Function(T?)? onChanged, required String? Function(T?) validator }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF3B82F6), size: 20)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w500),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
        hint: Text('Pilih $label'),
      ),
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextFormField(
        initialValue: value,
        key: Key(value), // Untuk memastikan field di-rebuild saat value berubah
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.info_rounded, color: Color(0xFF10B981), size: 20)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFF1F5F9), // Warna sedikit berbeda untuk menandakan read-only
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w500),
        readOnly: true,
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final circlePaint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 25, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 15, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
