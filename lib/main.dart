import 'package:flutter/material.dart';
import 'widgets/app_widgets.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/students/screens/students_screen.dart';
import 'features/courses/screens/courses_screen.dart';
import 'features/payments/screens/fees_screen.dart';
import 'features/staff/screens/staff_screen.dart';
import 'features/login/screens/login_screen.dart';

void main() => runApp(const CoachingApp());

class CoachingApp extends StatelessWidget {
  const CoachingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AK Coaching Manager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const LoginScreen(),

      routes: {
        '/home': (context) => const MainShell(),
        '/add-student': (context) => const StudentsScreen(),
        '/add-payment': (context) => const FeesScreen(),
        '/courses': (context) => const CoursesScreen(),
      },
    );
  }
}

// ───────────────── MAIN SHELL ─────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    StudentsScreen(),
    CoursesScreen(),
    FeesScreen(),
    StaffScreen(),
  ];

  final _items = const [
    _NavItem("Dashboard", Icons.dashboard),
    _NavItem("Students", Icons.school),
    _NavItem("Courses", Icons.menu_book),
    _NavItem("Fees", Icons.payments),
    _NavItem("Staff", Icons.badge),
  ];

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: isWeb
          ? Row(
              children: [
                // 💻 Sidebar
                _SideMenu(
                  items: _items,
                  selectedIndex: _index,
                  onTap: (i) => setState(() => _index = i),
                ),

                // 📄 Content
                Expanded(
                  child: _screens[_index],
                ),
              ],
            )
          : IndexedStack(
              index: _index,
              children: _screens,
            ),

      // 📱 Bottom Navigation (Mobile only)
      bottomNavigationBar: isWeb
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: _items
                  .map((e) => NavigationDestination(
                        icon: Icon(e.icon),
                        label: e.label,
                      ))
                  .toList(),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              height: 62,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
            ),
    );
  }
}

// ───────────────── NAV ITEM ─────────────────
class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

// ───────────────── SIDEBAR (WEB) ─────────────────
class _SideMenu extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final Function(int) onTap;

  const _SideMenu({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF111827),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // 🔥 App Name
          const Text(
            "AK Coaching",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          // 📌 Menu Items
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = i == selectedIndex;

            return InkWell(
              onTap: () => onTap(i),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color:
                          isSelected ? Colors.blue : Colors.white70,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.blue
                            : Colors.white70,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),

          const Spacer(),

          // Footer
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "AK Coaching v1.0",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}