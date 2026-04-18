import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class SelectedCourse {
  int? courseId;
  String? timeSlot;

  SelectedCourse({this.courseId, this.timeSlot});
}

class UpdateStudentScreen extends StatefulWidget {
  final Student student;

  const UpdateStudentScreen({super.key, required this.student});

  @override
  State<UpdateStudentScreen> createState() =>
      _UpdateStudentScreenState();
}

class _UpdateStudentScreenState extends State<UpdateStudentScreen> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _father = TextEditingController();
  final _mobile = TextEditingController();
  final _altMobile = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  final _admDate = TextEditingController();
  final _totalFee = TextEditingController();
  final _paidNow = TextEditingController();
  final _dueDate = TextEditingController();

  String _gender = 'male';

  List<Course> _courses = [];
  List<SelectedCourse> _selectedCourses = [];

  final _studentSvc = StudentService();
  final _courseSvc = CourseService();

  bool _saving = false;

  final List<String> _timeSlots = [
    "11:00 TO 02:00",
    "02:00 TO 05:00",
    "05:00 TO 07:00",
    "11:00 TO 05:00",
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _prefill();
  }

  void _prefill() {
    final s = widget.student;

    _name.text = s.name;
    _father.text = s.fatherName;
    _mobile.text = s.mobile;
    _email.text = s.email;
    _dob.text = s.dob;
    _admDate.text = s.admissionDate;
    _totalFee.text = s.totalFee.toStringAsFixed(0);
    _paidNow.text = s.paid.toStringAsFixed(0);
    _dueDate.text = s.nextDueDate ?? '';
    _gender = s.gender;

    // ⚠️ Courses prefill depends on API response
    // If courses not coming → keep empty
  }

  Future<void> _loadCourses() async {
    final list = await _courseSvc.getAll();
    setState(() => _courses = list);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Map<String, String> _parseSlot(String slot) {
    final parts = slot.split("TO");
    return {
      "start": "${parts[0].trim()}:00",
      "end": "${parts[1].trim()}:00",
    };
  }

  Future<void> _update() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);

    final coursesPayload = _selectedCourses
        .where((c) => c.courseId != null && c.timeSlot != null)
        .map((c) {
      final parsed = _parseSlot(c.timeSlot!);
      return {
        "course_id": c.courseId,
        "start_time": parsed['start'],
        "end_time": parsed['end'],
      };
    }).toList();

    final body = {
      'name': _name.text.trim(),
      'father_name': _father.text.trim(),
      'mobile': _mobile.text.trim(),
      'alternate_mobile': _altMobile.text.trim(),
      'email': _email.text.trim(),
      'dob': _dob.text.trim(),
      'gender': _gender,
      'admission_date': _admDate.text.trim(),
      'courses': coursesPayload,
      'total_fee': double.tryParse(_totalFee.text) ?? 0,
      'paid_now': double.tryParse(_paidNow.text) ?? 0,
      if (_dueDate.text.isNotEmpty)
        'next_due_date': _dueDate.text.trim(),
    };

    try {
      await _studentSvc.update(widget.student.id!, body);

      if (mounted) {
        showSnack(context, "Student Updated");
        Navigator.pop(context, true);
      }
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }

    setState(() => _saving = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _father.dispose();
    _mobile.dispose();
    _altMobile.dispose();
    _email.dispose();
    _dob.dispose();
    _admDate.dispose();
    _totalFee.dispose();
    _paidNow.dispose();
    _dueDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Student")),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader("PERSONAL INFO"),

            AppField(controller: _name, label: "Name"),
            const SizedBox(height: 10),

            AppField(controller: _father, label: "Father Name"),
            const SizedBox(height: 10),

            AppField(controller: _mobile, label: "Mobile"),
            const SizedBox(height: 10),

            AppField(controller: _altMobile, label: "Alternate Mobile"),
            const SizedBox(height: 10),

            AppField(controller: _email, label: "Email"),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _pickDate(_dob),
              child: AbsorbPointer(
                child: AppField(controller: _dob, label: "DOB"),
              ),
            ),

            const SizedBox(height: 20),
            const SectionHeader("COURSES"),

            ..._selectedCourses.map((item) {
              return Column(
                children: [
                  DropdownButtonFormField<int?>(
                    value: item.courseId,
                    items: _courses.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => item.courseId = v),
                  ),

                  Wrap(
                    children: _timeSlots.map((slot) {
                      return ChoiceChip(
                        label: Text(slot),
                        selected: item.timeSlot == slot,
                        onSelected: (_) =>
                            setState(() => item.timeSlot = slot),
                      );
                    }).toList(),
                  ),

                  const Divider()
                ],
              );
            }),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCourses.add(SelectedCourse());
                });
              },
              child: const Text("Add Course"),
            ),

            const SectionHeader("FEES"),

            AppField(controller: _totalFee, label: "Total Fee"),
            const SizedBox(height: 10),

            AppField(controller: _paidNow, label: "Paid Now"),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _pickDate(_dueDate),
              child: AbsorbPointer(
                child: AppField(
                    controller: _dueDate,
                    label: "Next Due Date"),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saving ? null : _update,
              child: _saving
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text("Update Student"),
            )
          ],
        ),
      ),
    );
  }
}