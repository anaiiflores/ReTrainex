import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart'; // Para el texto "VÍDEO PRÓXIMAMENTE"
import '../../core/theme/app_colors.dart';

/// Área rectangular donde se mostrará el vídeo demostrativo de un ejercicio.
/// Si [videoUrl] es null muestra un placeholder con texto "VÍDEO PRÓXIMAMENTE".
/// Si [videoUrl] tiene valor muestra un icono de play (reproductor real pendiente).
/// [isWide] adapta la altura al modo tablet/escritorio.
class VideoAreaWidget extends StatelessWidget {
  final String? videoUrl; // URL del vídeo — null cuando el backend aún no lo ha añadido
  final bool isWide;      // true en pantallas ≥600px de ancho

  const VideoAreaWidget({
    super.key,
    required this.videoUrl,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = isWide ? 240 : 180; // Más alto en pantallas anchas

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: videoUrl != null
          // ── Vídeo disponible: muestra botón de play centrado ────────────
          ? const Center(
              child: Icon(Icons.play_circle_outline_rounded,
                  color: AppColors.primary, size: 64),
              // TODO: reemplazar con un reproductor de vídeo real (video_player, chewie, etc.)
            )
          // ── Sin URL: placeholder "próximamente" ─────────────────────────
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.4), // Semitransparente
                    size: 48),
                const SizedBox(height: 10),
                Text(
                  LocaleManager.strings.videoComingSoon, // "VÍDEO PRÓXIMAMENTE" / "VIDEO COMING SOON"
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5, // Espaciado amplio estilo etiqueta técnica
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
