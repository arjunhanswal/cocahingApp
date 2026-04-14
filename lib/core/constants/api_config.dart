// ─────────────────────────────────────────────────────────────────────────────
// lib/core/constants/api_config.dart
//
// 🔧 CHANGE BASE URL HERE — ONE PLACE, AFFECTS ENTIRE APP
// ─────────────────────────────────────────────────────────────────────────────

class ApiConfig {
  // ── 🌐 Base URL — update this to switch environments ──────────────────────
  static const String baseUrl = 'https://coachingapp.codezhub.tech';
  // static const String baseUrl = 'https://api.yourcoaching.com'; // production

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Endpoints ──────────────────────────────────────────────────────────────
  // Students
  static const String students         = '/api/students';
  static String studentById(int id)    => '/api/students/$id';
  static String assignCourse(int id)   => '/api/students/$id/assign-course';

  // Courses
  static const String courses          = '/api/courses';
  static String courseById(int id)     => '/api/courses/$id';

  // Payments
  static const String payments         = '/api/payments';
  static String paymentHistory(int id) => '/api/payments/$id';
  static const String fees             = '/api/fees';

  // Staff
  static const String staff            = '/api/staff';
  static String staffById(int id)      => '/api/staff/$id';

  // Dashboard
  static const String dashSummary      = '/api/dashboard/summary';
  static const String dashMonthly      = '/api/dashboard/monthly';
  static const String dashRecent       = '/api/dashboard/recent-students';
}
