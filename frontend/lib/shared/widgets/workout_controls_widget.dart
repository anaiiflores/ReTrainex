import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart';
import '../../core/theme/app_colors.dart';
import 'workout_control_button_widget.dart'; // WorkoutControlButton — extraído a su propio archivo

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

// WorkoutControlButton está definido en workout_control_button_widget.dart
