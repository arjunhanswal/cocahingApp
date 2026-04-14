import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';
import 'student_form_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _svc = StudentService();
  List<Student> _all = [];
  List<Student> _filtered = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getAll();
      if (mounted) setState(() { _all = list; _applyFilter(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    _filtered = q.isEmpty
        ? List.from(_all)
        : _all.where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.mobile.contains(q) ||
            s.email.toLowerCase().contains(q)).toList();
  }

  Future<void> _delete(Student s) async {
    if (s.id == null) return;
    final ok = await confirmDelete(context, s.name);
    if (!ok) return;
    try {
      await _svc.delete(s.id!);
      showSnack(context, '${s.name} deleted');
      _load();
    } catch (e) { showSnack(context, e.toString(), error: true); }
  }

  Future<void> _openForm([Student? student]) async {
    final result = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => StudentFormScreen(existing: student)));
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎓 Students')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
            decoration: InputDecoration(
              hintText: 'Search name, mobile, email...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() { _search = ''; _applyFilter(); }),
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            Text('${_filtered.length} students',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
        Expanded(
          child: _loading
              ? const LoadingView()
              : _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : _filtered.isEmpty
                      ? _EmptyState(onAdd: _openForm)
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _StudentCard(
                              student: _filtered[i],
                              onEdit: () => _openForm(_filtered[i]),
                              onDelete: () => _delete(_filtered[i]),
                            ),
                          ),
                        ),
        ),
      ]),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit, onDelete;
  const _StudentCard({required this.student, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final progress = student.totalFee > 0
        ? (student.paid / student.totalFee).clamp(0.0, 1.0)
        : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text('${student.mobile} • ${student.classTime}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            StatusBadge(student.feeStatus),
            PopupMenuButton<String>(
              onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'delete') onDelete(); },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppColors.danger))),
              ],
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                  AppColors.statusColor(student.feeStatus)),
            ),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _FeeText('Paid: ₹${student.paid.toStringAsFixed(0)}', AppColors.success),
            _FeeText('Due: ₹${student.pending.toStringAsFixed(0)}', AppColors.danger),
            _FeeText('Total: ₹${student.totalFee.toStringAsFixed(0)}', AppColors.textMuted),
          ]),
          if (student.nextDueDate != null && student.nextDueDate!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Next due: ${student.nextDueDate}',
                style: const TextStyle(fontSize: 11, color: AppColors.warning)),
          ],
        ]),
      ),
    );
  }
}

class _FeeText extends StatelessWidget {
  final String text;
  final Color color;
  const _FeeText(this.text, this.color);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600));
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.school_outlined, size: 60, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      const Text('No students yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 6),
      const Text('Add your first student', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add Student')),
    ]),
  );
}
