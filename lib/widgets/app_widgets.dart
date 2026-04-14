import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// App Colors
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // 🌈 Primary Palette (Modern Indigo-Blue)
  static const primary   = Color(0xFF4F46E5); // Indigo (softer than dark blue)
  static const secondary = Color(0xFF6366F1); // Light Indigo
  static const accent    = Color(0xFF06B6D4); // Cyan (fresh)

  // ✅ Status Colors (more vibrant & modern)
  static const success   = Color(0xFF22C55E); // Green
  static const warning   = Color(0xFFF59E0B); // Amber
  static const danger    = Color(0xFFEF4444); // Red

  // 🎨 Backgrounds
  static const bg        = Color(0xFFF8FAFC); // Softer background
  static const card      = Colors.white;

  // 📝 Text Colors
  static const textDark  = Color(0xFF0F172A); // Rich dark (better than grey)
  static const textMuted = Color(0xFF64748B); // Modern grey

  // 📦 Borders
  static const border    = Color(0xFFE2E8F0);

  // 🎯 Gradient Options (for dashboard cards)
  static const gradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo → Purple
    [Color(0xFF06B6D4), Color(0xFF3B82F6)], // Cyan → Blue
    [Color(0xFF22C55E), Color(0xFF4ADE80)], // Green
    [Color(0xFFF59E0B), Color(0xFFFBBF24)], // Amber
    [Color(0xFFEF4444), Color(0xFFF87171)], // Red
  ];

  static Color statusColor(String s) {
    switch (s) {
      case 'Paid':
        return success;
      case 'Partial':
        return warning;
      default:
        return danger;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────────
final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surface: AppColors.bg,
  ),
  scaffoldBackgroundColor: AppColors.bg,
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  ),
  cardTheme: CardTheme(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.border),
    ),
    margin: EdgeInsets.zero,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0F3FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Colored status badge
class StatusBadge extends StatelessWidget {
  final String label;
  const StatusBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// Stat card for dashboard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ]),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

/// Simple loading indicator
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

/// Error view with retry
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 52, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ]),
      ),
    );
  }
}

/// Section header label
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted,
            letterSpacing: 0.4)),
  );
}

/// App-wide text field helper
class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? icon;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
    ),
  );
}

/// Confirm delete dialog
Future<bool> confirmDelete(BuildContext context, String item) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Remove "$item"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  ) ?? false;
}

/// Show snackbar
void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? AppColors.danger : AppColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}
