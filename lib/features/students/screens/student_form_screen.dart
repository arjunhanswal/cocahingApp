// import 'package:flutter/material.dart';
// import '../../../core/api/services.dart';
// import '../../../core/models/models.dart';
// import '../../../widgets/app_widgets.dart';

// class StudentFormScreen extends StatefulWidget {
//   final Student? existing;
//   const StudentFormScreen({super.key, this.existing});
//   @override
//   State<StudentFormScreen> createState() => _StudentFormScreenState();
// }

// class _StudentFormScreenState extends State<StudentFormScreen> {
//   final _form = GlobalKey<FormState>();
//   final _name      = TextEditingController();
//   final _father    = TextEditingController();
//   final _mobile    = TextEditingController();
//   final _email     = TextEditingController();
//   final _dob       = TextEditingController();
//   final _admDate   = TextEditingController();
//   final _totalFee  = TextEditingController();
//   final _paidNow   = TextEditingController();
//   final _dueDate   = TextEditingController();

//   String _gender = 'male';
//   String _classTime = 'Morning';
//   int? _courseId;

//   final _studentSvc = StudentService();
//   final _courseSvc  = CourseService();
//   List<Course> _courses = [];
//   bool _saving = false;

//   bool get _isEdit => widget.existing != null;

//   @override
//   void initState() {
//     super.initState();
//     _loadCourses();
//     if (_isEdit) _prefill(widget.existing!);
//   }

//   void _prefill(Student s) {
//     _name.text     = s.name;
//     _father.text   = s.fatherName;
//     _mobile.text   = s.mobile;
//     _email.text    = s.email;
//     _dob.text      = s.dob;
//     _admDate.text  = s.admissionDate;
//     _totalFee.text = s.totalFee.toStringAsFixed(0);
//     _paidNow.text  = s.paid.toStringAsFixed(0);
//     _dueDate.text  = s.nextDueDate ?? '';
//     _gender        = s.gender.isNotEmpty ? s.gender : 'male';
//     _classTime     = s.classTime.isNotEmpty ? s.classTime : 'Morning';
//     _courseId      = s.courseId;
//   }

//   Future<void> _loadCourses() async {
//     try {
//       final list = await _courseSvc.getAll();
//       if (mounted) setState(() => _courses = list);
//     } catch (_) {}
//   }

//   @override
//   void dispose() {
//     for (final c in [_name, _father, _mobile, _email, _dob, _admDate, _totalFee, _paidNow, _dueDate]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_form.currentState!.validate()) return;
//     setState(() => _saving = true);

//     final body = {
//       'name':           _name.text.trim(),
//       'father_name':    _father.text.trim(),
//       'mobile':         _mobile.text.trim(),
//       'email':          _email.text.trim(),
//       'dob':            _dob.text.trim(),
//       'gender':         _gender,
//       'admission_date': _admDate.text.trim(),
//       'class_time':     _classTime,
//       if (_courseId != null) 'course_id': _courseId,
//       'total_fee':      double.tryParse(_totalFee.text) ?? 0,
//       'paid_now':       double.tryParse(_paidNow.text) ?? 0,
//       if (_dueDate.text.isNotEmpty) 'next_due_date': _dueDate.text.trim(),
//     };

//     try {
//       if (_isEdit) {
//         await _studentSvc.update(widget.existing!.id!, body);
//       } else {
//         await _studentSvc.create(body);
//       }
//       if (mounted) {
//         showSnack(context, _isEdit ? 'Student updated!' : 'Student added!');
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (mounted) { showSnack(context, e.toString(), error: true); setState(() => _saving = false); }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_isEdit ? 'Edit Student' : 'Add Student')),
//       body: Form(
//         key: _form,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             const SectionHeader('PERSONAL INFO'),
//             AppField(controller: _name, label: 'Full Name *', icon: Icons.person_outline,
//                 validator: (v) => v!.isEmpty ? 'Required' : null),
//             const SizedBox(height: 10),
//             AppField(controller: _father, label: 'Father\'s Name', icon: Icons.family_restroom),
//             const SizedBox(height: 10),
//             AppField(controller: _mobile, label: 'Mobile *', icon: Icons.phone_outlined,
//                 keyboardType: TextInputType.phone,
//                 validator: (v) => v!.length < 10 ? 'Enter valid mobile' : null),
//             const SizedBox(height: 10),
//             AppField(controller: _email, label: 'Email', icon: Icons.email_outlined,
//                 keyboardType: TextInputType.emailAddress),
//             const SizedBox(height: 10),
//             AppField(controller: _dob, label: 'Date of Birth (YYYY-MM-DD)', icon: Icons.cake_outlined),
//             const SizedBox(height: 10),
//             // Gender
//             DropdownButtonFormField<String>(
//               value: _gender,
//               decoration: const InputDecoration(labelText: 'Gender'),
//               items: ['male', 'female', 'other']
//                   .map((g) => DropdownMenuItem(value: g, child: Text(g.toUpperCase())))
//                   .toList(),
//               onChanged: (v) => setState(() => _gender = v!),
//             ),
//             const SizedBox(height: 20),
//             const SectionHeader('ADMISSION INFO'),
//             AppField(controller: _admDate, label: 'Admission Date (YYYY-MM-DD)', icon: Icons.calendar_today_outlined,
//                 validator: (v) => v!.isEmpty ? 'Required' : null),
//             const SizedBox(height: 10),
//             // Class Time
//             DropdownButtonFormField<String>(
//               value: _classTime,
//               decoration: const InputDecoration(labelText: 'Class Time'),
//               items: ['Morning', 'Afternoon', 'Evening']
//                   .map((t) => DropdownMenuItem(value: t, child: Text(t)))
//                   .toList(),
//               onChanged: (v) => setState(() => _classTime = v!),
//             ),
//             const SizedBox(height: 10),
//             // Course
//             DropdownButtonFormField<int?>(
//               value: _courseId,
//               decoration: const InputDecoration(labelText: 'Course (optional)'),
//               items: [
//                 const DropdownMenuItem<int?>(value: null, child: Text('— Select course —')),
//                 ..._courses.map((c) => DropdownMenuItem<int?>(
//                     value: c.id,
//                     child: Text('${c.name} (₹${c.totalFee.toStringAsFixed(0)})'))),
//               ],
//               onChanged: (v) {
//                 setState(() {
//                   _courseId = v;
//                   if (v != null) {
//                     final course = _courses.firstWhere((c) => c.id == v);
//                     _totalFee.text = course.totalFee.toStringAsFixed(0);
//                   }
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             const SectionHeader('FEE DETAILS'),
//             AppField(controller: _totalFee, label: 'Total Fee (₹) *', icon: Icons.currency_rupee,
//                 keyboardType: TextInputType.number,
//                 validator: (v) => v!.isEmpty ? 'Required' : null),
//             const SizedBox(height: 10),
//             AppField(controller: _paidNow, label: 'Paid Now (₹)', icon: Icons.payments_outlined,
//                 keyboardType: TextInputType.number),
//             const SizedBox(height: 10),
//             AppField(controller: _dueDate, label: 'Next Due Date (YYYY-MM-DD)', icon: Icons.event_outlined),
//             const SizedBox(height: 28),
//             ElevatedButton(
//               onPressed: _saving ? null : _save,
//               child: _saving
//                   ? const SizedBox(width: 20, height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                   : Text(_isEdit ? 'Update Student' : 'Add Student'),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? existing;
  const StudentFormScreen({super.key, this.existing});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _father = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  final _admDate = TextEditingController();
  final _totalFee = TextEditingController();
  final _paidNow = TextEditingController();
  final _dueDate = TextEditingController();

  String _gender = 'male';
  String _classTime = 'Morning';
  int? _courseId;

  final _studentSvc = StudentService();
  final _courseSvc = CourseService();

  List<Course> _courses = [];
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    if (_isEdit) _prefill(widget.existing!);
  }

  void _prefill(Student s) {
    _name.text = s.name;
    _father.text = s.fatherName;
    _mobile.text = s.mobile;
    _email.text = s.email;
    _dob.text = s.dob;
    _admDate.text = s.admissionDate;
    _totalFee.text = s.totalFee.toStringAsFixed(0);
    _paidNow.text = s.paid.toStringAsFixed(0);
    _dueDate.text = s.nextDueDate ?? '';
    _gender = s.gender.isNotEmpty ? s.gender : 'male';
    _classTime = s.classTime.isNotEmpty ? s.classTime : 'Morning';
    _courseId = s.courseId;
  }

  Future<void> _loadCourses() async {
    try {
      final list = await _courseSvc.getAll();
      if (mounted) setState(() => _courses = list);
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _father,
      _mobile,
      _email,
      _dob,
      _admDate,
      _totalFee,
      _paidNow,
      _dueDate
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ✅ DATE PICKER
  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();

    DateTime initialDate = now;
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateTime.parse(controller.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year.toString().padLeft(4, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);

    final body = {
      'name': _name.text.trim(),
      'father_name': _father.text.trim(),
      'mobile': _mobile.text.trim(),
      'email': _email.text.trim(),
      'dob': _dob.text.trim(),
      'gender': _gender,
      'admission_date': _admDate.text.trim(),
      'class_time': _classTime,
      if (_courseId != null) 'course_id': _courseId,
      'total_fee': double.tryParse(_totalFee.text) ?? 0,
      'paid_now': double.tryParse(_paidNow.text) ?? 0,
      if (_dueDate.text.isNotEmpty)
        'next_due_date': _dueDate.text.trim(),
    };

    try {
      if (_isEdit) {
        await _studentSvc.update(widget.existing!.id!, body);
      } else {
        await _studentSvc.create(body);
      }

      if (mounted) {
        showSnack(context,
            _isEdit ? 'Student updated!' : 'Student added!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString(), error: true);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Student' : 'Add Student'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader('PERSONAL INFO'),

            AppField(
              controller: _name,
              label: 'Full Name *',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),

            AppField(
              controller: _father,
              label: 'Father\'s Name',
              icon: Icons.family_restroom,
            ),
            const SizedBox(height: 10),

            AppField(
              controller: _mobile,
              label: 'Mobile *',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v!.length < 10 ? 'Enter valid mobile' : null,
            ),
            const SizedBox(height: 10),

            AppField(
              controller: _email,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // ✅ DOB PICKER
            GestureDetector(
              onTap: () => _pickDate(_dob),
              child: AbsorbPointer(
                child: AppField(
                  controller: _dob,
                  label: 'Date of Birth (YYYY-MM-DD)',
                  icon: Icons.cake_outlined,
                ),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['male', 'female', 'other']
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v!),
            ),

            const SizedBox(height: 20),
            const SectionHeader('ADMISSION INFO'),

            // ✅ ADMISSION DATE PICKER
            GestureDetector(
              onTap: () => _pickDate(_admDate),
              child: AbsorbPointer(
                child: AppField(
                  controller: _admDate,
                  label: 'Admission Date (YYYY-MM-DD)',
                  icon: Icons.calendar_today_outlined,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _classTime,
              decoration: const InputDecoration(labelText: 'Class Time'),
              items: ['Morning', 'Afternoon', 'Evening']
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _classTime = v!),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<int?>(
              value: _courseId,
              decoration:
                  const InputDecoration(labelText: 'Course (optional)'),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('— Select course —')),
                ..._courses.map(
                  (c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(
                        '${c.name} (₹${c.totalFee.toStringAsFixed(0)})'),
                  ),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _courseId = v;
                  if (v != null) {
                    final course =
                        _courses.firstWhere((c) => c.id == v);
                    _totalFee.text =
                        course.totalFee.toStringAsFixed(0);
                  }
                });
              },
            ),

            const SizedBox(height: 20),
            const SectionHeader('FEE DETAILS'),

            AppField(
              controller: _totalFee,
              label: 'Total Fee (₹) *',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),

            AppField(
              controller: _paidNow,
              label: 'Paid Now (₹)',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // ✅ DUE DATE PICKER
            GestureDetector(
              onTap: () => _pickDate(_dueDate),
              child: AbsorbPointer(
                child: AppField(
                  controller: _dueDate,
                  label: 'Next Due Date (YYYY-MM-DD)',
                  icon: Icons.event_outlined,
                ),
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEdit ? 'Update Student' : 'Add Student'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}