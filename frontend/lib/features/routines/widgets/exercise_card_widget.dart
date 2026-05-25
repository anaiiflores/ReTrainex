import 'package:flutter/material.dart';
import '../../../core/strings/locale_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../exercises/models/exercise_detail_model.dart'; // ExerciseModel

/// Tarjeta compacta de un ejercicio individual.
/// Se usa en RoutineDetailScreen para listar los ejercicios de una rutina.
/// Muestra la miniatura, el nombre, el subtítulo (series/reps o minutos) y un botón de play.
class ExerciseCardWidget extends StatelessWidget {
  final ExerciseModel exercise; // Datos del ejercicio a mostrar

  /// Callback cuando el usuario pulsa el botón de play.
  /// null → el botón sigue renderizándose pero no dispara nada al pulsarse.
  final VoidCallback? onPlayTap;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ── Miniatura ────────────────────────────────────────────────────
          _ExerciseThumbnail(imageUrl: exercise.imageUrl), // Imagen o icono fallback
          const SizedBox(width: 14),
          // ── Nombre y subtítulo ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name, // "Rotación de hombros"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // Subtítulo: prioriza series×reps; si no, muestra los minutos
                  exercise.series != null && exercise.reps != null
                      ? LocaleManager.strings.exerciseSubtitleSeries(exercise.series!, exercise.reps!)
                      // Ej: "3 SERIES · 10 REPS" — '!' seguro porque acabamos de verificar != null
                      : exercise.minutes != null
                          ? LocaleManager.strings.exerciseSubtitleMinutes(exercise.minutes!)
                          // Ej: "2 MIN"
                          : '', // Sin datos → cadena vacía (no muestra nada)
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Botón de play ────────────────────────────────────────────────
          GestureDetector(
            onTap: onPlayTap, // null → GestureDetector ignora el tap
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

/// Miniatura cuadrada del ejercicio.
/// Muestra la imagen de red si está disponible; si no, muestra un icono genérico.
/// Clase privada (`_`) — solo se usa dentro de este archivo.
class _ExerciseThumbnail extends StatelessWidget {
  final String? imageUrl; // null → usa icono fallback

  const _ExerciseThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: imageUrl != null
          // ── Imagen disponible ─────────────────────────────────────────
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9), // Recorta para respetar el border-radius
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover, // Rellena sin deformar la imagen
                // Si la URL es inválida o no carga → muestra el icono fallback
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.accessibility_new_rounded,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),
            )
          // ── Sin imagen: icono placeholder ─────────────────────────────
          : const Icon(
              Icons.accessibility_new_rounded, // Silueta humana genérica
              color: AppColors.textSecondary,
              size: 32,
            ),
    );
  }
}
