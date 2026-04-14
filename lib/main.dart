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
      title: 'Coaching Manager',
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

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    StudentsScreen(),
    CoursesScreen(),
    FeesScreen(),
    StaffScreen(),
  ];

  static const _items = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: 'Students',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Courses',
    ),
    NavigationDestination(
      icon: Icon(Icons.payments_outlined),
      selectedIcon: Icon(Icons.payments),
      label: 'Fees',
    ),
    NavigationDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge),
      label: 'Staff',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _items,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        height: 62,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}
