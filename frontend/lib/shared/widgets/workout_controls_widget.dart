import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart';
import '../../core/theme/app_colors.dart';

/// Fila de botones circulares de control de sesión: play/pausa, stop y (opcional) skip.
/// Se usa en WorkoutExerciseScreen y WorkoutPreparationScreen.
/// Es stateless — toda la lógica de estado vive en la pantalla que lo contiene.
class WorkoutControlsWidget extends StatelessWidget {
  final bool isPaused;          // true → la sesión está en pausa, el botón muestra "play"
  final VoidCallback onPause;   // Alterna entre pausar y reanudar
  final VoidCallback onStop;    // Detiene la sesión y vuelve al inicio
  final VoidCallback? onSkip;   // null → no se muestra el botón de omitir
  /// Texto del tooltip del botón skip. null → usa la cadena localizada por defecto.
  final String? skipLabel;
  /// true → el botón de pausa/play se reemplaza por un botón de "siguiente ejercicio"
  /// (usado cuando el ejercicio no tiene temporizador — modo timeless).
  final bool nextMode;

  const WorkoutControlsWidget({
    super.key,
    required this.isPaused,
    required this.onPause,
    required this.onStop,
    this.onSkip,
    this.skipLabel,
    this.nextMode = false, // Por defecto modo normal (pausa/play)
  });

  @override
  Widget build(BuildContext context) {
    final s = LocaleManager.strings; // Alias para reducir verbosidad
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Botones centrados horizontalmente
      children: [
        // ── Botón principal: siguiente / pausa / play ──────────────────────
        WorkoutControlButton(
          icon: nextMode
              ? Icons.arrow_forward_rounded // En modo timeless → flecha "siguiente"
              : (isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded), // Play si pausado, pause si activo
          color: AppColors.primary,
          onTap: onPause, // El callback se llama "onPause" pero actúa también como onPlay y onNext
          tooltip: nextMode
              ? s.controlsNextExercise
              : (isPaused ? s.controlsResume : s.controlsPause),
        ),
        const SizedBox(width: 28), // Espacio entre botones
        // ── Botón de stop ─────────────────────────────────────────────────
        WorkoutControlButton(
          icon: Icons.stop_rounded,
          color: Colors.redAccent, // Rojo para indicar acción destructiva
          onTap: onStop,
          tooltip: s.restStopSession,
        ),
        // ── Botón de skip (opcional) ──────────────────────────────────────
        if (onSkip != null) ...[ // Solo se renderiza si se pasó el callback
          const SizedBox(width: 28),
          WorkoutControlButton(
            icon: Icons.skip_next_rounded,
            color: AppColors.textSecondary, // Gris — acción menos prominente
            onTap: onSkip!,                 // '!' seguro porque ya verificamos != null
            tooltip: skipLabel ?? s.controlsSkipExercise, // Texto personalizable o el por defecto
          ),
        ],
      ],
    );
  }
}

/// Botón circular individual de control de sesión.
/// Extraído a su propia clase para poder reutilizarlo fuera de WorkoutControlsWidget
/// (ej. en WorkoutPreparationScreen para el botón de omitir preparación).
class WorkoutControlButton extends StatelessWidget {
  final IconData icon;        // Icono del botón
  final Color color;          // Color del fondo circular
  final VoidCallback onTap;   // Acción al pulsar
  final String tooltip;       // Texto de ayuda (accesibilidad + dispositivos con cursor)

  const WorkoutControlButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip, // Se muestra al mantener pulsado (móvil) o al pasar el cursor (web)
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle, // Botón perfectamente redondo
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35), // Halo del mismo color del botón
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30), // Icono blanco sobre el color del botón
        ),
      ),
    );
  }
}
