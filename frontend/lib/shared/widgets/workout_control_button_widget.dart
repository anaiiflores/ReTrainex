import 'package:flutter/material.dart';

/// Botón circular individual de control de sesión.
/// Extraído de workout_controls_widget.dart porque se usa directamente
/// en pantallas que no necesitan WorkoutControlsWidget completo
/// (WorkoutPreparationScreen, WorkoutRestScreen).
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
