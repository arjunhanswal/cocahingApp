import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _svc = StaffService();
  List<Staff> _staff = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getAll();
      if (mounted) setState(() { _staff = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(Staff s) async {
    if (s.id == null) return;
    final ok = await confirmDelete(context, s.name);
    if (!ok) return;
    try {
      await _svc.delete(s.id!);
      showSnack(context, '${s.name} deleted');
      _load();
    } catch (e) { showSnack(context, e.toString(), error: true); }
  }

  Future<void> _openForm([Staff? staff]) async {
    final result = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => _StaffForm(existing: staff)));
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _staff.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.badge_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('No staff yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(onPressed: _openForm, icon: const Icon(Icons.add), label: const Text('Add Staff')),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _staff.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _StaffCard(
                          staff: _staff[i],
                          onEdit: () => _openForm(_staff[i]),
                          onDelete: () => _delete(_staff[i]),
                        ),
                      ),
                    ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback onEdit, onDelete;
  const _StaffCard({required this.staff, required this.onEdit, required this.onDelete});

  static const _roleColors = {
    'Teacher':        Color(0xFF1565C0),
    'Senior Teacher': Color(0xFF4A148C),
    'Admin':          Color(0xFFB71C1C),
    'Manager':        Color(0xFF2E7D32),
  };

  @override
  Widget build(BuildContext context) {
    final color = _roleColors[staff.role] ?? AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Text(
              staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(staff.role,
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 4),
            Text('Salary: ₹${staff.salary.toStringAsFixed(0)}/month',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ])),
          PopupMenuButton<String>(
            onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'delete') onDelete(); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete',
                  child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ]),
      ),
    );
  }
}

// ── Staff Form ────────────────────────────────────────────────────────────────
class _StaffForm extends StatefulWidget {
  final Staff? existing;
  const _StaffForm({this.existing});
  @override
  State<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<_StaffForm> {
  final _form   = GlobalKey<FormState>();
  final _name   = TextEditingController();
  final _salary = TextEditingController();
  String _role  = 'Teacher';
  final _svc = StaffService();
  bool _saving = false;
  bool get _isEdit => widget.existing != null;

  static const _roles = ['Teacher', 'Senior Teacher', 'Admin', 'Manager', 'Coordinator', 'Other'];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _name.text   = widget.existing!.name;
      _salary.text = widget.existing!.salary.toStringAsFixed(0);
      _role = _roles.contains(widget.existing!.role) ? widget.existing!.role : 'Teacher';
    }
  }

  @override
  void dispose() { _name.dispose(); _salary.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'name':   _name.text.trim(),
      'role':   _role,
      'salary': double.tryParse(_salary.text) ?? 0,
    };
    try {
      if (_isEdit) await _svc.update(widget.existing!.id!, body);
      else await _svc.create(body);
      if (mounted) { showSnack(context, _isEdit ? 'Staff updated!' : 'Staff added!'); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) { showSnack(context, e.toString(), error: true); setState(() => _saving = false); }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEdit ? 'Edit Staff' : 'Add Staff')),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(16), children: [
      AppField(controller: _name, label: 'Full Name *', icon: Icons.person_outline,
          validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _role,
        decoration: const InputDecoration(labelText: 'Role'),
        items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
        onChanged: (v) => setState(() => _role = v!),
      ),
      const SizedBox(height: 12),
      AppField(controller: _salary, label: 'Salary (₹/month) *', icon: Icons.currency_rupee,
          keyboardType: TextInputType.number,
          validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 28),
      ElevatedButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(_isEdit ? 'Update Staff' : 'Add Staff'),
      ),
    ])),
  );
}
