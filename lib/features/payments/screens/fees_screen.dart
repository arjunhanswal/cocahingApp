import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});
  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> with SingleTickerProviderStateMixin {
  final _svc = PaymentService();
  List<FeeSummary> _fees = [];
  bool _loading = true;
  String? _error;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getFeesList();
      if (mounted) setState(() { _fees = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<FeeSummary> _filter(String status) {
    if (status == 'all') return _fees;
    if (status == 'due') return _fees.where((f) => f.status == 'Pending' || f.status == 'Partial').toList();
    return _fees.where((f) => f.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalCollected = _fees.fold(0.0, (s, f) => s + f.paidAmount);
    final totalPending   = _fees.fold(0.0, (s, f) => s + f.pendingAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Fees'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Due / Partial'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : Column(children: [
                  // Summary header
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(children: [
                      _SumItem('Collected', '₹${_fmt(totalCollected)}', AppColors.success),
                      _SumItem('Pending', '₹${_fmt(totalPending)}', const Color(0xFFFF8A65)),
                      _SumItem('Students', '${_fees.length}', Colors.white),
                    ]),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _FeeList(fees: _filter('all'), onRefresh: _load),
                        _FeeList(fees: _filter('due'), onRefresh: _load),
                        _FeeList(fees: _filter('Paid'), onRefresh: _load),
                      ],
                    ),
                  ),
                ]),
    );
  }

  String _fmt(double v) => v >= 1000 ? '₹${(v / 1000).toStringAsFixed(1)}K' : '₹${v.toStringAsFixed(0)}';
}

class _SumItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SumItem(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]));
}

class _FeeList extends StatelessWidget {
  final List<FeeSummary> fees;
  final VoidCallback onRefresh;
  const _FeeList({required this.fees, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (fees.isEmpty) return const Center(child: Text('No records', style: TextStyle(color: AppColors.textMuted)));
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: fees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _FeeTile(fee: fees[i]),
      ),
    );
  }
}

class _FeeTile extends StatelessWidget {
  final FeeSummary fee;
  const _FeeTile({required this.fee});

  @override
  Widget build(BuildContext context) {
    final progress = fee.totalFee > 0 ? (fee.paidAmount / fee.totalFee).clamp(0.0, 1.0) : 0.0;
    final statusColor = AppColors.statusColor(fee.status);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showPaymentSheet(context, fee),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  fee.studentName.isNotEmpty ? fee.studentName[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fee.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                if (fee.nextDueDate != null && fee.nextDueDate!.isNotEmpty)
                  Text('Due: ${fee.nextDueDate}',
                      style: const TextStyle(fontSize: 11, color: AppColors.warning)),
              ])),
              StatusBadge(fee.status),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress, minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Paid: ₹${fee.paidAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
              Text('Due: ₹${fee.pendingAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600)),
              Text('Total: ₹${fee.totalFee.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, FeeSummary fee) {
    if (fee.studentId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PaymentSheet(fee: fee),
    );
  }
}

// ── Add Payment Bottom Sheet ───────────────────────────────────────────────────
class _PaymentSheet extends StatefulWidget {
  final FeeSummary fee;
  const _PaymentSheet({required this.fee});
  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _amountCtrl  = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _svc = PaymentService();
  bool _saving = false;
  List<Payment> _history = [];
  bool _histLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final list = await _svc.getHistory(widget.fee.studentId!);
      if (mounted) setState(() { _history = list; _histLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _histLoading = false);
    }
  }

  Future<void> _pay() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      showSnack(context, 'Enter a valid amount', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await _svc.addPayment(
        studentId: widget.fee.studentId!,
        amount: amount,
        nextDueDate: _dueDateCtrl.text.trim().isEmpty ? null : _dueDateCtrl.text.trim(),
      );
      if (mounted) {
        showSnack(context, 'Payment of ₹${amount.toStringAsFixed(0)} recorded!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) { showSnack(context, e.toString(), error: true); setState(() => _saving = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Payment — ${widget.fee.studentName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 4),
        // Balance summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Pending', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Text('₹${widget.fee.pendingAmount.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 14),
        AppField(controller: _amountCtrl, label: 'Amount (₹) *', icon: Icons.currency_rupee,
            keyboardType: TextInputType.number),
        const SizedBox(height: 10),
        AppField(controller: _dueDateCtrl, label: 'Next Due Date (YYYY-MM-DD)', icon: Icons.event_outlined),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _pay,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: _saving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirm Payment'),
          ),
        ),
        // Payment History
        if (!_histLoading && _history.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Payment History',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final p = _history[i];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  title: Text('₹${p.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(p.date ?? '', style: const TextStyle(fontSize: 11)),
                  trailing: p.nextDueDate != null
                      ? Text('Due: ${p.nextDueDate}',
                          style: const TextStyle(fontSize: 11, color: AppColors.warning))
                      : null,
                );
              },
            ),
          ),
        ],
      ]),
    );
  }
}
