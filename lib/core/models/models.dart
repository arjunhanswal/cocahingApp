// ─────────────────────────────────────────────────────────────────────────────
// lib/core/models/models.dart  — all models matching the Postman API schema
// ─────────────────────────────────────────────────────────────────────────────

// // ── Student ───────────────────────────────────────────────────────────────────
// class Student {
//   final int? id;
//   final String name;
//   final String fatherName;
//   final String mobile;
//   final String email;
//   final String dob;
//   final String gender;
//   final String admissionDate;
//   final String classTime;
//   final int? courseId;
//   final double totalFee;
//   final double paidNow;
//   final String? nextDueDate;
//   // Computed from API
//   final double? paidAmount;
//   final double? pendingAmount;
//   final String? courseName;

//   Student({
//     this.id,
//     required this.name,
//     required this.fatherName,
//     required this.mobile,
//     required this.email,
//     required this.dob,
//     required this.gender,
//     required this.admissionDate,
//     required this.classTime,
//     this.courseId,
//     required this.totalFee,
//     required this.paidNow,
//     this.nextDueDate,
//     this.paidAmount,
//     this.pendingAmount,
//     this.courseName,
//   });

//   double get paid => paidAmount ?? paidNow;
//   double get pending => pendingAmount ?? (totalFee - paidNow);
//   String get feeStatus {
//     if (paid >= totalFee) return 'Paid';
//     if (paid > 0) return 'Partial';
//     return 'Pending';
//   }

//   factory Student.fromJson(Map<String, dynamic> j) => Student(
//   id:            j['id'] as int?,
//   name:          j['name'] ?? '',
//   fatherName:    j['father_name'] ?? '',
//   mobile:        j['mobile'] ?? '',
//   email:         j['email'] ?? '',
//   dob:           j['dob'] ?? '',
//   gender:        j['gender'] ?? '',
//   admissionDate: j['admission_date'] ?? '',
//   classTime:     j['class_time'] ?? '',
//   courseId:      j['course_id'] as int?,
//   totalFee:      _toDouble(j['total_fee']),

//   // ✅ FIX HERE
//   paidNow:       _toDouble(j['paid_now'] ?? j['paid_amount']),

//   nextDueDate:   j['next_due_date']?.toString(),

//   paidAmount:    j['paid_amount'] != null ? _toDouble(j['paid_amount']) : null,
//   pendingAmount: j['pending_amount'] != null ? _toDouble(j['pending_amount']) : null,

//   courseName:    j['course']?.toString() ?? j['course_name']?.toString(),
// );

//   Map<String, dynamic> toJson() => {
//     'name':           name,
//     'father_name':    fatherName,
//     'mobile':         mobile,
//     'email':          email,
//     'dob':            dob,
//     'gender':         gender,
//     'admission_date': admissionDate,
//     'class_time':     classTime,
//     if (courseId != null) 'course_id': courseId,
//     'total_fee':      totalFee,
//     'paid_now':       paidNow,
//     if (nextDueDate != null) 'next_due_date': nextDueDate,
//   };
// }

// ── Course ────────────────────────────────────────────────────────────────────
class Course {
  final int? id;
  final String name;
  final double totalFee;
  final String duration;

  Course({
    this.id,
    required this.name,
    required this.totalFee,
    required this.duration,
  });

  factory Course.fromJson(Map<String, dynamic> j) => Course(
    id:       j['id'] as int?,
    name:     j['name'] ?? '',
    totalFee: _toDouble(j['total_fee']),
    duration: j['duration'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name':      name,
    'total_fee': totalFee,
    'duration':  duration,
  };
}

// ── Payment ───────────────────────────────────────────────────────────────────
class Payment {
  final int? id;
  final int studentId;
  final double amount;
  final String? nextDueDate;
  final String? date;
  final String? mode;

  Payment({
    this.id,
    required this.studentId,
    required this.amount,
    this.nextDueDate,
    this.date,
    this.mode,
  });

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
    id:          j['id'] as int?,
    studentId:   (j['student_id'] ?? 0) as int,
    amount:      _toDouble(j['amount']),
    nextDueDate: j['next_due_date']?.toString(),
    date:        j['date']?.toString() ?? j['created_at']?.toString(),
    mode:        j['mode']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'student_id':   studentId,
    'amount':       amount,
    if (nextDueDate != null) 'next_due_date': nextDueDate,
  };
}

// ── Fee Summary (from /api/fees) ──────────────────────────────────────────────
class FeeSummary {
  final int? studentId;
  final String studentName;
  final double totalFee;
  final double paidAmount;
  final double pendingAmount;
  final String? nextDueDate;

  FeeSummary({
    this.studentId,
    required this.studentName,
    required this.totalFee,
    required this.paidAmount,
    required this.pendingAmount,
    this.nextDueDate,
  });

  String get status {
    if (paidAmount >= totalFee) return 'Paid';
    if (paidAmount > 0) return 'Partial';
    return 'Pending';
  }

  factory FeeSummary.fromJson(Map<String, dynamic> j) => FeeSummary(
    studentId:     j['student_id'] as int?,
    studentName:   j['student_name'] ?? j['name'] ?? '',
    totalFee:      _toDouble(j['total_fee']),
    paidAmount:    _toDouble(j['paid_amount']),
    pendingAmount: _toDouble(j['pending_amount']),
    nextDueDate:   j['next_due_date']?.toString(),
  );
}

// ── Staff ─────────────────────────────────────────────────────────────────────
class Staff {
  final int? id;
  final String name;
  final String role;
  final double salary;

  Staff({
    this.id,
    required this.name,
    required this.role,
    required this.salary,
  });

  factory Staff.fromJson(Map<String, dynamic> j) => Staff(
    id:     j['id'] as int?,
    name:   j['name'] ?? '',
    role:   j['role'] ?? '',
    salary: _toDouble(j['salary']),
  );

  Map<String, dynamic> toJson() => {
    'name':   name,
    'role':   role,
    'salary': salary,
  };
}

// ── Dashboard ─────────────────────────────────────────────────────────────────
class DashboardSummary {
  final int totalStudents;
  final int totalCourses;
  final double totalRevenue;
  final double totalPending;
  final int totalStaff;

  DashboardSummary({
    required this.totalStudents,
    required this.totalCourses,
    required this.totalRevenue,
    required this.totalPending,
    required this.totalStaff,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    totalStudents: (j['total_students'] ?? j['students'] ?? 0) as int,
    totalCourses:  (j['total_courses']  ?? j['courses']  ?? 0) as int,
    totalRevenue:  _toDouble(j['total_revenue'] ?? j['revenue'] ?? 0),
    totalPending:  _toDouble(j['total_pending'] ?? j['pending'] ?? 0),
    totalStaff:    (j['total_staff']    ?? j['staff']    ?? 0) as int,
  );
}

class MonthlyRevenue {
  final String month;
  final double amount;

  MonthlyRevenue({required this.month, required this.amount});

  factory MonthlyRevenue.fromJson(Map<String, dynamic> j) => MonthlyRevenue(
    month:  j['month']?.toString() ?? '',
    amount: _toDouble(j['amount'] ?? j['revenue'] ?? 0),
  );
}

// ── Helper ────────────────────────────────────────────────────────────────────
double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
class Student {
  final int? id;
  final String name;
  final String fatherName;
  final String mobile;
  final String email;
  final String dob;
  final String gender;
  final String admissionDate;
  final String classTime;
  final int? courseId;
  final double totalFee;
  final double paidNow;
  final String? nextDueDate;

  // API computed values
  final double? paidAmount;
  final double? pendingAmount;
  final String? courseName;

  Student({
    this.id,
    required this.name,
    required this.fatherName,
    required this.mobile,
    required this.email,
    required this.dob,
    required this.gender,
    required this.admissionDate,
    required this.classTime,
    this.courseId,
    required this.totalFee,
    required this.paidNow,
    this.nextDueDate,
    this.paidAmount,
    this.pendingAmount,
    this.courseName,
  });

  // ✅ Correct calculation
  double get paid => paidAmount ?? paidNow;
  double get pending => pendingAmount ?? (totalFee - paidNow);

  String get feeStatus {
    if (paid >= totalFee) return 'Paid';
    if (paid > 0) return 'Partial';
    return 'Pending';
  }

  // ✅ Clean Date Format
  static String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    return date.split('T').first; // convert ISO → YYYY-MM-DD
  }

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id: j['id'] as int?,
        name: j['name'] ?? '',
        fatherName: j['father_name'] ?? '',
        mobile: j['mobile'] ?? '',
        email: j['email'] ?? '',

        // ✅ formatted dates
        dob: _formatDate(j['dob']),
        admissionDate: _formatDate(j['admission_date']),

        gender: j['gender'] ?? '',
        classTime: j['class_time'] ?? '',
        courseId: j['course_id'] as int?,
        totalFee: _toDouble(j['total_fee']),

        // ✅ FIXED mapping
        paidNow: _toDouble(j['paid_now'] ?? j['paid_amount']),

        nextDueDate: _formatDate(j['next_due_date']),

        paidAmount:
            j['paid_amount'] != null ? _toDouble(j['paid_amount']) : null,

        pendingAmount:
            j['pending_amount'] != null ? _toDouble(j['pending_amount']) : null,

        // ✅ supports both API formats
        courseName: j['course']?.toString() ??
            j['course_name']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'father_name': fatherName,
        'mobile': mobile,
        'email': email,
        'dob': dob,
        'gender': gender,
        'admission_date': admissionDate,
        'class_time': classTime,
        if (courseId != null) 'course_id': courseId,
        'total_fee': totalFee,
        'paid_now': paidNow,
        if (nextDueDate != null && nextDueDate!.isNotEmpty)
          'next_due_date': nextDueDate,
      };
}