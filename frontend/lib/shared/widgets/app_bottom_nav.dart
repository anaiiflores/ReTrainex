import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppNavItem {
  final IconData icon;
  final String label;
  const AppNavItem({required this.icon, required this.label});
}

/// Lista global de tabs de navegación principal.
/// Se usa tanto en BottomNavigationBar (móvil) como en NavigationRail (web).
const List<AppNavItem> kAppNavItems = [
  AppNavItem(icon: Icons.home_rounded, label: 'INICIO'),
  AppNavItem(icon: Icons.fitness_center_rounded, label: 'RUTINAS'),
  AppNavItem(icon: Icons.trending_up_rounded, label: 'PROGRESO'),
  AppNavItem(icon: Icons.settings_rounded, label: 'AJUSTES'),
];

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      unselectedLabelStyle: const TextStyle(letterSpacing: 0.8),
      items: kAppNavItems
          .map((n) => BottomNavigationBarItem(
                icon: Icon(n.icon, size: 26),
                activeIcon: Icon(n.icon, size: 28),
                label: n.label,
              ))
          .toList(),
    );
  }
}
