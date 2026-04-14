import '../api/api_client.dart';
import '../constants/api_config.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Student Service
// ─────────────────────────────────────────────────────────────────────────────
class StudentService {
  final _client = ApiClient();

  Future<List<Student>> getAll() async {
    final data = await _client.get(ApiConfig.students);
    final list = data is List ? data : (data['data'] ?? data['students'] ?? []);
    return (list as List).map((e) => Student.fromJson(e)).toList();
  }

  Future<Student> getById(int id) async {
    final data = await _client.get(ApiConfig.studentById(id));
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Student.fromJson(json);
  }

  Future<Student> create(Map<String, dynamic> body) async {
    final data = await _client.post(ApiConfig.students, body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Student.fromJson(json);
  }

  Future<Student> update(int id, Map<String, dynamic> body) async {
    final data = await _client.put(ApiConfig.studentById(id), body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Student.fromJson(json);
  }

  Future<void> delete(int id) async {
    await _client.delete(ApiConfig.studentById(id));
  }

  Future<void> assignCourse(int studentId, int courseId) async {
    await _client.put(ApiConfig.assignCourse(studentId), {'course_id': courseId});
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Course Service
// ─────────────────────────────────────────────────────────────────────────────
class CourseService {
  final _client = ApiClient();

  Future<List<Course>> getAll() async {
    final data = await _client.get(ApiConfig.courses);
    final list = data is List ? data : (data['data'] ?? data['courses'] ?? []);
    return (list as List).map((e) => Course.fromJson(e)).toList();
  }

  Future<Course> create(Map<String, dynamic> body) async {
    final data = await _client.post(ApiConfig.courses, body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Course.fromJson(json);
  }

  Future<Course> update(int id, Map<String, dynamic> body) async {
    final data = await _client.put(ApiConfig.courseById(id), body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Course.fromJson(json);
  }

  Future<void> delete(int id) async {
    await _client.delete(ApiConfig.courseById(id));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Service
// ─────────────────────────────────────────────────────────────────────────────
class PaymentService {
  final _client = ApiClient();

  Future<Payment> addPayment({
    required int studentId,
    required double amount,
    String? nextDueDate,
  }) async {
    final body = {
      'student_id': studentId,
      'amount': amount,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
    };
    final data = await _client.post(ApiConfig.payments, body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Payment.fromJson(json);
  }

  Future<List<Payment>> getHistory(int studentId) async {
    final data = await _client.get(ApiConfig.paymentHistory(studentId));
    final list = data is List ? data : (data['data'] ?? data['payments'] ?? []);
    return (list as List).map((e) => Payment.fromJson(e)).toList();
  }

  Future<List<FeeSummary>> getFeesList() async {
    final data = await _client.get(ApiConfig.fees);
    final list = data is List ? data : (data['data'] ?? data['fees'] ?? []);
    return (list as List).map((e) => FeeSummary.fromJson(e)).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staff Service
// ─────────────────────────────────────────────────────────────────────────────
class StaffService {
  final _client = ApiClient();

  Future<List<Staff>> getAll() async {
    final data = await _client.get(ApiConfig.staff);
    final list = data is List ? data : (data['data'] ?? data['staff'] ?? []);
    return (list as List).map((e) => Staff.fromJson(e)).toList();
  }

  Future<Staff> create(Map<String, dynamic> body) async {
    final data = await _client.post(ApiConfig.staff, body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Staff.fromJson(json);
  }

  Future<Staff> update(int id, Map<String, dynamic> body) async {
    final data = await _client.put(ApiConfig.staffById(id), body);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return Staff.fromJson(json);
  }

  Future<void> delete(int id) async {
    await _client.delete(ApiConfig.staffById(id));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Service
// ─────────────────────────────────────────────────────────────────────────────
class DashboardService {
  final _client = ApiClient();

  Future<DashboardSummary> getSummary() async {
    final data = await _client.get(ApiConfig.dashSummary);
    final json = data is Map && data.containsKey('data') ? data['data'] : data;
    return DashboardSummary.fromJson(json);
  }

  Future<List<MonthlyRevenue>> getMonthly() async {
    final data = await _client.get(ApiConfig.dashMonthly);
    final list = data is List ? data : (data['data'] ?? data['monthly'] ?? []);
    return (list as List).map((e) => MonthlyRevenue.fromJson(e)).toList();
  }

  Future<List<Student>> getRecentStudents() async {
    final data = await _client.get(ApiConfig.dashRecent);
    final list = data is List ? data : (data['data'] ?? data['students'] ?? []);
    return (list as List).map((e) => Student.fromJson(e)).toList();
  }
}
