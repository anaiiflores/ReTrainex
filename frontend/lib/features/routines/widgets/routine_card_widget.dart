import 'package:flutter/material.dart';
import '../../../core/strings/locale_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../models/routine_model.dart'; // RoutineModel y RoutineStatus

/// Tarjeta de una rutina individual en la lista semanal.
/// Su aspecto visual varía según el estado de la rutina:
///   - `completed` → fondo oscuro, tick verde, sin botón de inicio.
///   - `today`     → fondo azul oscuro, borde azul grueso, botón "INICIAR".
///   - `upcoming`  → fondo gris neutro, icono de candado, sin interacción.
class RoutineCardWidget extends StatelessWidget {
  final RoutineModel routine; // Datos de la rutina (día, título, duración, estado)

  /// Callback llamado cuando el usuario pulsa "INICIAR".
  /// null → el botón no dispara ninguna acción (solo cuando status == today).
  final VoidCallback? onStartTap;

  const RoutineCardWidget({
    super.key,
    required this.routine,
    this.onStartTap,
  });

  bool get _isToday => routine.status == RoutineStatus.today;
  bool get _isCompleted => routine.status == RoutineStatus.completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Fondo azul muy oscuro si es la rutina de hoy; neutro para el resto
        color: _isToday ? const Color(0xFF0D1F3C) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isToday ? AppColors.primary : AppColors.border, // Borde azul destacado para hoy
          width: _isToday ? 2 : 1, // Borde más grueso para hoy
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),       // Día + estado (tick, "HOY", "PRÓXIMO")
          const SizedBox(height: 8),
          Text(
            routine.title,      // "Movilidad de Hombro"
            style: TextStyle(
              // Las completadas tienen el título en gris para indicar que ya no son accionables
              color: _isCompleted ? AppColors.textSecondary : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Tag de duración (ej. "15 MIN")
              _buildTag(
                icon: Icons.access_time_rounded,
                label: '${routine.minutes} MIN',
                color: _isToday ? Colors.orange : AppColors.textSecondary, // Naranja si es hoy
              ),
              const SizedBox(width: 14),
              // Tag de dificultad (ej. "MEDIA")
              _buildTag(
                icon: Icons.bolt_rounded,
                label: routine.difficulty,
                color: _difficultyColor(routine.difficulty), // Rojo/naranja/gris según dificultad
              ),
              const Spacer(), // Empuja la acción hacia la derecha
              _buildAction(), // Tick / botón INICIAR / candado según status
            ],
          ),
        ],
      ),
    );
  }

  /// Fila con el nombre del día y el estado de la rutina (color + texto).
  Widget _buildHeader() {
    final String statusLabel;
    final Color statusColor;

    // Determina el texto y color del indicador de estado según RoutineStatus
    switch (routine.status) {
      case RoutineStatus.completed:
        statusLabel = LocaleManager.strings.statusCompleted; // "COMPLETADO"
        statusColor = Colors.greenAccent;
        break;
      case RoutineStatus.today:
        statusLabel = LocaleManager.strings.statusToday;    // "HOY"
        statusColor = AppColors.primary;
        break;
      case RoutineStatus.upcoming:
        statusLabel = LocaleManager.strings.statusUpcoming; // "PRÓXIMO"
        statusColor = AppColors.textSecondary;
        break;
    }

    return Row(
      children: [
        Text(
          routine.day, // "LUNES", "MARTES", etc.
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 6),
        // Punto separador del color del estado
        Text('•', style: TextStyle(color: statusColor, fontWeight: FontWeight.w900)),
        const SizedBox(width: 6),
        Text(
          statusLabel, // Texto de estado con el color correspondiente
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  /// Tag pequeño con icono y etiqueta de texto.
  Widget _buildTag({required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Widget de acción al final de la fila, adaptado al estado de la rutina.
  Widget _buildAction() {
    switch (routine.status) {
      case RoutineStatus.completed:
        // Círculo verde con tick — la rutina ya fue completada
        return Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        );
      case RoutineStatus.today:
        // Botón "INICIAR" que invoca el callback de la pantalla padre
        return ElevatedButton(
          onPressed: onStartTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: Size.zero,                                  // Sin tamaño mínimo impuesto
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,         // Área de toque ajustada al botón
          ),
          child: Text(
            LocaleManager.strings.startSession, // "INICIAR"
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 13),
          ),
        );
      case RoutineStatus.upcoming:
        // Icono de candado — la rutina no es hoy y no se puede iniciar
        return Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textSecondary.withValues(alpha: 0.5), // Semitransparente
          size: 24,
        );
    }
  }

  /// Color del tag de dificultad según el nivel.
  Color _difficultyColor(String d) {
    switch (d.toUpperCase()) {
      case 'ALTA':
        return Colors.redAccent;  // Rojo → alta dificultad
      case 'MEDIA':
        return Colors.orange;     // Naranja → dificultad media
      default:
        return AppColors.textSecondary; // Gris → baja o desconocida
    }
  }
}
