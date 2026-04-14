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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Future.wait([
        _svc.getSummary(),
        _svc.getMonthly(),
        _svc.getRecentStudents(),
      ]);

      setState(() {
        _summary = res[0] as DashboardSummary;
        _monthly = res[1] as List<MonthlyRevenue>;
        _recent = res[2] as List<Student>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _Header(summary: _summary!),
                      const SizedBox(height: 20),

                      _StatsGrid(summary: _summary!),
                      const SizedBox(height: 20),

                      _QuickActions(),
                      const SizedBox(height: 20),

                      _RevenueChart(data: _monthly),
                      const SizedBox(height: 20),

                      _RecentStudents(students: _recent),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}


class _Header extends StatelessWidget {
  final DashboardSummary summary;
  const _Header({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "AK Coaching Manager",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Manage students, fees & performance",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}


class _StatsGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 5; // 💻 large web
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,

            // 🔥 IMPORTANT: control height
            childAspectRatio: 1.6, // 👈 increase = smaller height

            children: [
              _StatCard("Students", "${summary.totalStudents}", Icons.school, Colors.blue),
              _StatCard("Courses", "${summary.totalCourses}", Icons.book, Colors.purple),
              _StatCard("Revenue", "₹${summary.totalRevenue.toStringAsFixed(0)}", Icons.trending_up, Colors.green),
              _StatCard("Pending", "₹${summary.totalPending.toStringAsFixed(0)}", Icons.warning, Colors.red),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}



class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ActionButton(Icons.person_add, "Add Student"),
          const SizedBox(width: 10),
          _ActionButton(Icons.payment, "Add Payment"),
          const SizedBox(width: 10),
          _ActionButton(Icons.receipt, "Courses"),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton(this.icon, this.label);

  void _handleTap(BuildContext context) {
    if (label == "Add Student") {
      Navigator.pushNamed(context, "/add-student");
    } else if (label == "Add Payment") {
      Navigator.pushNamed(context, "/add-payment");
    } else if (label == "Courses") {
      Navigator.pushNamed(context, "/courses");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}



class _RevenueChart extends StatelessWidget {
  final List<MonthlyRevenue> data;
  const _RevenueChart({required this.data});

  String _getMonthName(dynamic month) {
    // handle both int and string
    int m = 1;

    if (month is int) {
      m = month;
    } else {
      m = int.tryParse(month.toString()) ?? 1;
    }

    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    return (m >= 1 && m <= 12) ? months[m - 1] : "NA";
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty
        ? 1.0
        : data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Revenue",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 140,
              child: data.isEmpty
                  ? const Center(child: Text("No Data"))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.map((e) {
                        final h = maxValue == 0
                            ? 0.0
                            : (e.amount / maxValue) * 100;

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: h,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getMonthName(e.month),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RecentStudents extends StatelessWidget {
  final List<Student> students;
  const _RecentStudents({required this.students});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Students",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...students.take(5).map((s) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(s.name.isNotEmpty ? s.name[0] : "?"),
                  ),
                  title: Text(s.name),
                  subtitle: Text(s.courseName ?? "Course"),
                  trailing: StatusBadge(s.feeStatus),
                ),
              ))
        ],
      ),
    );
  }
}