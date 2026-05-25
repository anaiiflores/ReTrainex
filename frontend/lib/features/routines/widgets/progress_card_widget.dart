import 'package:flutter/material.dart';
import '../../../core/strings/locale_manager.dart';
import '../../../core/theme/app_colors.dart';

/// Tarjeta de progreso semanal.
/// Muestra una barra horizontal con el porcentaje de sesiones completadas esta semana,
/// un mensaje de ánimo adaptado al estado y el conteo numérico de sesiones.
/// Se usa en RoutinesListScreen.
class ProgressCardWidget extends StatelessWidget {
  final int completed; // Sesiones completadas esta semana
  final int total;     // Total de sesiones planificadas esta semana

  const ProgressCardWidget({
    super.key,
    required this.completed,
    required this.total,
  });

  /// Mensaje de motivación adaptado al estado del progreso semanal.
  String get _message {
    if (completed == 0) return LocaleManager.strings.progressStart;     // "¡A EMPEZAR!"
    if (completed == total) return LocaleManager.strings.progressDone;  // "¡SEMANA COMPLETA!"
    return LocaleManager.strings.progressOnTrack;                        // "¡VAS MUY BIEN!"
  }

  @override
  Widget build(BuildContext context) {
    // Fracción 0.0–1.0 para la barra de progreso; evita división por cero con total == 0
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta de sección en gris
          Text(
            LocaleManager.strings.weeklyProgress, // "PROGRESO SEMANAL"
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Mensaje de ánimo grande
          Text(
            _message, // "¡VAS MUY BIEN!" / "¡SEMANA COMPLETA!" / "¡A EMPEZAR!"
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          // Barra de progreso horizontal
          ClipRRect(
            borderRadius: BorderRadius.circular(4), // Extremos redondeados de la barra
            child: LinearProgressIndicator(
              value: progress,                                         // Fracción 0.0–1.0
              minHeight: 6,                                            // Altura de la barra en px
              backgroundColor: AppColors.border,                      // Fondo gris de la barra vacía
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), // Barra azul
            ),
          ),
          const SizedBox(height: 10),
          // Contador textual: "2 de 3 sesiones completadas"
          Text(
            LocaleManager.strings.progressSessions(completed, total),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
