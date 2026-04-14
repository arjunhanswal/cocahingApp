// import 'dart:math';
// import 'package:flutter/material.dart';
// import '../../../core/api/services.dart';
// import '../../../core/models/models.dart';
// import '../../../widgets/app_widgets.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   final _svc = DashboardService();

//   DashboardSummary? _summary;
//   List<MonthlyRevenue> _monthly = [];
//   List<Student> _recent = [];

//   bool _loading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final results = await Future.wait([
//         _svc.getSummary(),
//         _svc.getMonthly(),
//         _svc.getRecentStudents(),
//       ]);

//       if (mounted) {
//         setState(() {
//           _summary = results[0] as DashboardSummary;
//           _monthly = results[1] as List<MonthlyRevenue>;
//           _recent = results[2] as List<Student>;
//           _loading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _loading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _load,
//           )
//         ],
//       ),
//       body: _loading
//           ? const LoadingView()
//           : _error != null
//               ? ErrorView(message: _error!, onRetry: _load)
//               : RefreshIndicator(
//                   onRefresh: _load,
//                   child: ListView(
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       if (_summary != null) ...[
//                         _StatsGrid(summary: _summary!),
//                         const SizedBox(height: 20),
//                       ],
//                       if (_monthly.isNotEmpty) ...[
//                         const SectionHeader('Monthly Revenue'),
//                         _MonthlyBar(data: _monthly),
//                         const SizedBox(height: 20),
//                       ],
//                       if (_recent.isNotEmpty) ...[
//                         const SectionHeader('Recent Students'),
//                         ..._recent.take(5).map((e) => RecentStudentTile(e)),
//                       ],
//                     ],
//                   ),
//                 ),
//     );
//   }
// }

// class _StatsGrid extends StatelessWidget {
//   final DashboardSummary summary;
//   const _StatsGrid({required this.summary});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       childAspectRatio: 1.4,
//       children: [
//         StatCard(
//           title: 'Total Students',
//           value: '${summary.totalStudents}',
//           icon: Icons.school,
//         ),
//         StatCard(
//           title: 'Total Courses',
//           value: '${summary.totalCourses}',
//           icon: Icons.menu_book,
//         ),
//         StatCard(
//           title: 'Revenue',
//           value: '₹${_fmt(summary.totalRevenue)}',
//           icon: Icons.currency_rupee,
//         ),
//         StatCard(
//           title: 'Pending',
//           value: '₹${_fmt(summary.totalPending)}',
//           icon: Icons.warning_amber_rounded,
//         ),
//       ],
//     );
//   }

//   String _fmt(double v) =>
//       v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
// }

// class StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;

//   const StatCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//   });

//   LinearGradient _randomGradient() {
//     final gradients = [
//       [Color(0xFF6A11CB), Color(0xFF2575FC)],
//       [Color(0xFFFF416C), Color(0xFFFF4B2B)],
//       [Color(0xFF11998E), Color(0xFF38EF7D)],
//       [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
//       [Color(0xFFFFA17F), Color(0xFF00223E)],
//     ];
//     return LinearGradient(
//       colors: gradients[Random().nextInt(gradients.length)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: _randomGradient(),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SectionHeader extends StatelessWidget {
//   final String title;
//   const SectionHeader(this.title, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 4,
//           height: 18,
//           decoration: BoxDecoration(
//             color: Colors.blue,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _MonthlyBar extends StatelessWidget {
//   final List<MonthlyRevenue> data;
//   const _MonthlyBar({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final maxAmt = data.isEmpty
//         ? 1.0
//         : data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SizedBox(
//           height: 120,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: data.map((m) {
//               final ratio = maxAmt > 0 ? m.amount / maxAmt : 0.0;
//               return Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Container(
//                       height: 90 * ratio,
//                       margin: const EdgeInsets.symmetric(horizontal: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       m.month.substring(0, 3),
//                       style: const TextStyle(fontSize: 10),
//                     )
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class RecentStudentTile extends StatelessWidget {
//   final Student s;
//   const RecentStudentTile(this.s, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//           )
//         ],
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.blue.withOpacity(0.1),
//           child: Text(
//             s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
//             style: const TextStyle(
//               color: Colors.blue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(s.name),
//         subtitle: Text(s.courseName ?? 'Course #${s.courseId ?? '-'}'),
//         trailing: StatusBadge(s.feeStatus),
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _svc = DashboardService();

  DashboardSummary? _summary;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final summary = await _svc.getSummary();

      if (mounted) {
        setState(() {
          _summary = summary;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          )
        ],
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_summary != null)
                        _StatsGrid(summary: _summary!),
                    ],
                  ),
                ),
    );
  }
}

// ── Stats Grid ─────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatCard(
          title: 'Total Students',
          value: '${summary.totalStudents}',
          icon: Icons.school,
        ),
        StatCard(
          title: 'Total Courses',
          value: '${summary.totalCourses}',
          icon: Icons.menu_book,
        ),
        StatCard(
          title: 'Revenue',
          value: '₹${_fmt(summary.totalRevenue)}',
          icon: Icons.currency_rupee,
        ),
        StatCard(
          title: 'Pending',
          value: '₹${_fmt(summary.totalPending)}',
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
}

// ── Stat Card ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  LinearGradient _randomGradient() {
    final gradients = [
      [Color(0xFF6A11CB), Color(0xFF2575FC)],
      [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      [Color(0xFF11998E), Color(0xFF38EF7D)],
      [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
      [Color(0xFFFFA17F), Color(0xFF00223E)],
    ];
    return LinearGradient(
      colors: gradients[Random().nextInt(gradients.length)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _randomGradient(),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}