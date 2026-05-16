import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Fila de botones circulares (pausa/play + parar) y enlace de omitir.
/// Úsalo en cualquier pantalla de sesión activa.
class WorkoutControlsWidget extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback? onSkip;
  final String skipLabel;

  const WorkoutControlsWidget({
    super.key,
    required this.isPaused,
    required this.onPause,
    required this.onStop,
    this.onSkip,
    this.skipLabel = 'OMITIR EJERCICIO',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WorkoutControlButton(
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: AppColors.primary,
          onTap: onPause,
          tooltip: isPaused ? 'Continuar' : 'Pausar',
        ),
        const SizedBox(width: 28),
        WorkoutControlButton(
          icon: Icons.stop_rounded,
          color: Colors.redAccent,
          onTap: onStop,
          tooltip: 'Detener sesión',
        ),
        if (onSkip != null) ...[
          const SizedBox(width: 28),
          WorkoutControlButton(
            icon: Icons.skip_next_rounded,
            color: AppColors.textSecondary,
            onTap: onSkip!,
            tooltip: skipLabel,
          ),
        ],
      ],
    );
  }
}

/// Botón circular individual de control de sesión.
class WorkoutControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

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
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
