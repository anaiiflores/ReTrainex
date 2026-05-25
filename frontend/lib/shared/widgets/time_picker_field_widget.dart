import 'package:flutter/material.dart'; // TimeOfDay, showTimePicker, DayPeriod, etc.
import '../../core/theme/app_colors.dart';

/// Campo de selección de hora con formato 12h (AM/PM).
/// Al pulsar, abre el diálogo nativo de selección de hora de Flutter.
/// Cuando el usuario confirma, llama a [onChanged] con la hora en formato "H:MM AM/PM".
class TimePickerField extends StatelessWidget {
  /// Hora actual mostrada en el campo (ej. "10:30 AM").
  final String time;

  /// Función llamada cuando el usuario selecciona una nueva hora.
  /// Recibe la hora formateada como String.
  final ValueChanged<String> onChanged;

  const TimePickerField({
    super.key,
    required this.time,
    required this.onChanged,
  });

  /// Abre el diálogo de selección de hora y notifica el resultado.
  Future<void> _pick(BuildContext context) async {
    // ── Parseo de la hora inicial ────────────────────────────────────────
    final parts = time.split(' ');        // Divide "10:30 AM" en ["10:30", "AM"]
    final hm = parts[0].split(':');       // Divide "10:30" en ["10", "30"]
    int hour = int.parse(hm[0]);          // Hora en formato 12h
    final isPm = parts.length > 1 && parts[1] == 'PM'; // Detecta si es PM

    // Convierte de formato 12h a 24h para TimeOfDay (que usa 0–23)
    if (isPm && hour != 12) hour += 12;   // PM no-12 → sumar 12 (ej. 2 PM → 14)
    if (!isPm && hour == 12) hour = 0;    // 12 AM (medianoche) → 0 en formato 24h

    // ── Diálogo ──────────────────────────────────────────────────────────
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: int.parse(hm[1])), // Hora pre-seleccionada
      builder: (ctx, child) => Theme( // Sobrescribe el tema solo para este diálogo
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,   // Color del reloj y selección activa
            surface: AppColors.card,      // Fondo del diálogo
            onSurface: Colors.white,      // Texto sobre la superficie
          ),
        ),
        child: child!, // child! es seguro — Flutter siempre proporciona el widget del diálogo
      ),
    );

    if (picked == null) return; // El usuario canceló — no hacer nada

    // ── Formateo del resultado ────────────────────────────────────────────
    // hourOfPeriod devuelve 1–12; si es 0 (medianoche en formato 12h) → usamos 12
    final h = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final m = picked.minute.toString().padLeft(2, '0'); // "5" → "05"
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM'; // DayPeriod es el enum AM/PM de Flutter
    onChanged('$h:$m $period'); // Notifica al padre, ej. "2:05 PM"
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context), // Abre el diálogo al pulsar en cualquier parte del campo
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.primary, size: 20), // Icono de reloj
            const SizedBox(width: 12),
            Text(
              time, // Hora actual formateada
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 8, // Espaciado amplio para estilo de display
              ),
            ),
          ],
        ),
      ),
    );
  }
}
