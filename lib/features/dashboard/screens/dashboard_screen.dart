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
  List<MonthlyRevenue> _monthly = [];
  List<Student> _recent = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _svc.getSummary(),
        _svc.getMonthly(),
        _svc.getRecentStudents(),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as DashboardSummary;
          _monthly = results[1] as List<MonthlyRevenue>;
          _recent  = results[2] as List<Student>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
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
                      if (_summary != null) ...[
                        _StatsGrid(summary: _summary!),
                        const SizedBox(height: 20),
                      ],
                      if (_monthly.isNotEmpty) ...[
                        const SectionHeader('MONTHLY REVENUE'),
                        _MonthlyBar(data: _monthly),
                        const SizedBox(height: 20),
                      ],
                      if (_recent.isNotEmpty) ...[
                        const SectionHeader('RECENT STUDENTS'),
                        ..._recent.take(5).map((s) => _RecentStudentTile(s)),
                      ],
                    ],
                  ),
                ),
    );
  }
}

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
      childAspectRatio: 1.55,
      children: [
        StatCard(
          title: 'Total Students',
          value: '${summary.totalStudents}',
          icon: Icons.school,
          color: AppColors.primary,
        ),
        StatCard(
          title: 'Total Courses',
          value: '${summary.totalCourses}',
          icon: Icons.menu_book,
          color: AppColors.accent,
        ),
        StatCard(
          title: 'Revenue',
          value: '₹${_fmt(summary.totalRevenue)}',
          icon: Icons.currency_rupee,
          color: AppColors.success,
        ),
        StatCard(
          title: 'Pending',
          value: '₹${_fmt(summary.totalPending)}',
          icon: Icons.warning_amber_rounded,
          color: AppColors.danger,
        ),
      ],
    );
  }

  String _fmt(double v) => v >= 1000
      ? '${(v / 1000).toStringAsFixed(1)}K'
      : v.toStringAsFixed(0);
}

class _MonthlyBar extends StatelessWidget {
  final List<MonthlyRevenue> data;
  const _MonthlyBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxAmt = data.isEmpty ? 1.0
        : data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((m) {
              final ratio = maxAmt > 0 ? m.amount / maxAmt : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 80 * ratio,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.month.length > 3 ? m.month.substring(0, 3) : m.month,
                        style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RecentStudentTile extends StatelessWidget {
  final Student s;
  const _RecentStudentTile(this.s);

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(s.courseName ?? 'Course #${s.courseId ?? '-'}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: StatusBadge(s.feeStatus),
    ),
  );
}
