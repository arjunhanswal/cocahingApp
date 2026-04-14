import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _svc = CourseService();
  List<Course> _courses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getAll();
      if (mounted) setState(() { _courses = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(Course c) async {
    if (c.id == null) return;
    final ok = await confirmDelete(context, c.name);
    if (!ok) return;
    try {
      await _svc.delete(c.id!);
      showSnack(context, '${c.name} deleted');
      _load();
    } catch (e) { showSnack(context, e.toString(), error: true); }
  }

  Future<void> _openForm([Course? course]) async {
    final result = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => _CourseForm(existing: course)));
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 Courses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _courses.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.menu_book_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('No courses yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(onPressed: _openForm, icon: const Icon(Icons.add), label: const Text('Add Course')),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _courses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _CourseCard(
                          course: _courses[i],
                          onEdit: () => _openForm(_courses[i]),
                          onDelete: () => _delete(_courses[i]),
                        ),
                      ),
                    ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit, onDelete;
  const _CourseCard({required this.course, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.menu_book, color: AppColors.accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 2),
          Text('Duration: ${course.duration}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('₹${course.totalFee.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
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

// ── Course Form (inline in same file for brevity) ─────────────────────────────
class _CourseForm extends StatefulWidget {
  final Course? existing;
  const _CourseForm({this.existing});
  @override
  State<_CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<_CourseForm> {
  final _form = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _fee      = TextEditingController();
  final _duration = TextEditingController();
  final _svc = CourseService();
  bool _saving = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _name.text     = widget.existing!.name;
      _fee.text      = widget.existing!.totalFee.toStringAsFixed(0);
      _duration.text = widget.existing!.duration;
    }
  }

  @override
  void dispose() { _name.dispose(); _fee.dispose(); _duration.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'name':      _name.text.trim(),
      'total_fee': double.tryParse(_fee.text) ?? 0,
      'duration':  _duration.text.trim(),
    };
    try {
      if (_isEdit) await _svc.update(widget.existing!.id!, body);
      else await _svc.create(body);
      if (mounted) { showSnack(context, _isEdit ? 'Course updated!' : 'Course added!'); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) { showSnack(context, e.toString(), error: true); setState(() => _saving = false); }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEdit ? 'Edit Course' : 'Add Course')),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(16), children: [
      AppField(controller: _name, label: 'Course Name *', icon: Icons.menu_book_outlined,
          validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 12),
      AppField(controller: _fee, label: 'Total Fee (₹) *', icon: Icons.currency_rupee,
          keyboardType: TextInputType.number,
          validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 12),
      AppField(controller: _duration, label: 'Duration (e.g. 12 months)', icon: Icons.access_time,
          validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 28),
      ElevatedButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(_isEdit ? 'Update Course' : 'Add Course'),
      ),
    ])),
  );
}
