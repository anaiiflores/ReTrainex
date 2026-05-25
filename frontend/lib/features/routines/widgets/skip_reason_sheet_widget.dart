import 'package:flutter/material.dart';
import '../../../core/strings/locale_manager.dart';
import '../../../core/theme/app_colors.dart';

/// Razones por las que el paciente puede omitir un ejercicio.
/// El valor seleccionado se devuelve a la pantalla que abrió el sheet vía `Navigator.pop`.
enum SkipReason {
  dontKnow, // "No sé cómo hacerlo" — falta de conocimiento técnico
  cantNow,  // "No puedo ahora" — limitación temporal de tiempo o energía
  pain,     // "Me duele" — posible lesión o molestia, requiere atención del fisio
}

/// Pregunta que encabeza el bottom sheet — getter para que use siempre el idioma activo.
String get _kQuestion => LocaleManager.strings.skipQuestion; // "¿Por qué omites este ejercicio?"

/// Lista de opciones del selector con sus propiedades visuales.
/// Getter (no const) porque los labels vienen de LocaleManager y pueden cambiar con el idioma.
List<({String label, IconData icon, Color color, SkipReason reason})>
    get _kOptions => [
  (
    label: LocaleManager.strings.skipDontKnow,  // "No sé cómo hacerlo"
    icon: Icons.help_outline_rounded,
    color: AppColors.textSecondary,              // Gris — opción informativa, sin alarma
    reason: SkipReason.dontKnow,
  ),
  (
    label: LocaleManager.strings.skipCantNow,   // "No puedo ahora"
    icon: Icons.schedule_rounded,
    color: AppColors.textSecondary,
    reason: SkipReason.cantNow,
  ),
  (
    label: LocaleManager.strings.skipPain,      // "Me duele"
    icon: Icons.medical_services_outlined,
    color: Colors.redAccent,                     // Rojo — señal de alerta médica
    reason: SkipReason.pain,
  ),
];

/// Bottom sheet modal para seleccionar el motivo de omisión de un ejercicio.
/// Se muestra mediante `showModalBottomSheet` desde WorkoutExerciseScreen.
/// Al seleccionar una opción, hace `Navigator.pop(context, SkipReason)` para devolver el valor.
class SkipReasonSheet extends StatelessWidget {
  const SkipReasonSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32), // Margen inferior extra para el gesto home
      child: Column(
        mainAxisSize: MainAxisSize.min, // El sheet ocupa solo el espacio necesario para el contenido
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta que encabeza el sheet
          Text(
            _kQuestion,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Genera una opción por cada elemento de _kOptions
          ..._kOptions.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10), // Separación entre opciones
                child: _SkipOption(
                  label: o.label,
                  icon: o.icon,
                  color: o.color,
                  // Al pulsar → cierra el sheet y devuelve la razón seleccionada al llamador
                  onTap: () => Navigator.of(context).pop(o.reason),
                ),
              )),
        ],
      ),
    );
  }
}

/// Opción individual del selector de motivo de omisión.
/// Botón de ancho completo con icono + texto.
class _SkipOption extends StatelessWidget {
  final String label;      // Texto descriptivo de la opción
  final IconData icon;     // Icono que representa la razón
  final Color color;       // Color del icono y texto (gris o rojo)
  final VoidCallback onTap; // Acción al pulsar (devuelve la razón al padre)

  const _SkipOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppColors.textSecondary, // Gris por defecto
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Ancho completo del sheet
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
