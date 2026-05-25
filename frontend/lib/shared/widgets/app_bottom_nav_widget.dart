import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/strings/locale_manager.dart'; // Para los textos localizados de las pestañas

/// Datos de un ítem de navegación (icono + etiqueta).
/// Clase separada para que la lista de items sea reutilizable
/// tanto en BottomNavigationBar como en NavigationRail (pantallas anchas).
class AppNavItem {
  final IconData icon;  // Icono de la pestaña (de la librería Icons)
  final String label;   // Texto visible bajo el icono

  const AppNavItem({required this.icon, required this.label});
}

/// Lista global de los 4 tabs de navegación principal.
/// Es un getter (no una constante) porque los labels vienen de LocaleManager,
/// que puede cambiar en tiempo de ejecución si el usuario cambia el idioma.
/// WelcomeIniScreen y AppBottomNav la usan para mantenerse sincronizados.
List<AppNavItem> get kAppNavItems => [
  AppNavItem(icon: Icons.home_rounded,          label: LocaleManager.strings.navHome),      // Tab 0: Inicio
  AppNavItem(icon: Icons.fitness_center_rounded, label: LocaleManager.strings.navRoutines), // Tab 1: Rutinas
  AppNavItem(icon: Icons.trending_up_rounded,   label: LocaleManager.strings.navProgress),  // Tab 2: Progreso
  AppNavItem(icon: Icons.settings_rounded,      label: LocaleManager.strings.navSettings),  // Tab 3: Ajustes
];

/// Barra de navegación inferior.
/// Recibe el índice activo y un callback; la pantalla padre gestiona el estado.
/// Esto sigue el patrón "elevate state up" — el widget es stateless y tonto.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;           // Índice de la pestaña seleccionada actualmente
  final ValueChanged<int> onTap;    // Se llama con el nuevo índice al pulsar una pestaña

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,       // Pestaña actualmente marcada
      onTap: onTap,                     // Notifica al padre del nuevo índice seleccionado
      backgroundColor: AppColors.surface, // Fondo ligeramente más claro que el Scaffold
      selectedItemColor: AppColors.primary,    // Azul para el ítem activo
      unselectedItemColor: AppColors.textSecondary, // Gris para ítems inactivos
      type: BottomNavigationBarType.fixed, // Todos los ítems visibles siempre (sin desplazamiento)
      selectedFontSize: 11,   // Tamaño fuente del label activo
      unselectedFontSize: 10, // Tamaño fuente de los labels inactivos
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8, // Espaciado entre letras para el estilo HUD
      ),
      unselectedLabelStyle: const TextStyle(letterSpacing: 0.8),
      items: kAppNavItems
          .map((item) => BottomNavigationBarItem( // Convierte cada AppNavItem en un ítem de Flutter
                icon: Icon(item.icon, size: 26),        // Icono tamaño normal (inactivo)
                activeIcon: Icon(item.icon, size: 28),  // Icono ligeramente mayor cuando está activo
                label: item.label,
              ))
          .toList(), // map() devuelve un Iterable; toList() lo convierte a List requerida
    );
  }
}
