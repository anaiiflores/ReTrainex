import 'dart:async'; // Timer — ciclo automático del slideshow
import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart'; // Para el texto "VÍDEO PRÓXIMAMENTE"
import '../../core/theme/app_colors.dart';

/// Área rectangular donde se muestra el contenido visual de un ejercicio.
///
/// Jerarquía de prioridad:
///   1. [videoUrl] → placeholder de reproductor (icono ▶ — vídeo real pendiente).
///   2. [imageAssets] con ≥1 elemento → slideshow automático entre fotogramas.
///   3. Sin datos → placeholder "VÍDEO PRÓXIMAMENTE".
///
/// [isWide] adapta la altura al modo tablet/escritorio.
class VideoAreaWidget extends StatelessWidget {
  final String?
      videoUrl; // URL del vídeo — null cuando el backend no lo ha añadido
  final List<String>?
      imageAssets; // Rutas locales de los fotogramas del ejercicio
  final bool isWide; // true en pantallas ≥600px de ancho

  const VideoAreaWidget({
    super.key,
    required this.videoUrl,
    this.imageAssets,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = isWide ? 240 : 180; // Más alto en pantallas anchas

    // ── 1. Vídeo disponible ───────────────────────────────────────────────
    if (videoUrl != null) {
      return _Shell(
        height: height,
        child: const Center(
          child: Icon(Icons.play_circle_outline_rounded,
              color: AppColors.primary, size: 64),
          // TODO: reemplazar con reproductor real (video_player, chewie, etc.)
        ),
      );
    }

    // ── 2. Imágenes de ejercicio ──────────────────────────────────────────
    final images = imageAssets;
    if (images != null && images.isNotEmpty) {
      return _Shell(
        height: height,
        child: _ExerciseSlideshow(images: images),
      );
    }

    // ── 3. Placeholder "próximamente" ─────────────────────────────────────
    return _Shell(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off_rounded,
              color: AppColors.textSecondary
                  .withValues(alpha: 0.4), // Semitransparente
              size: 48),
          const SizedBox(height: 10),
          Text(
            LocaleManager.strings.videoComingSoon, // "VÍDEO PRÓXIMAMENTE"
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contenedor compartido ────────────────────────────────────────────────────

/// Recuadro con fondo, bordes redondeados y borde — compartido por los tres estados.
class _Shell extends StatelessWidget {
  final double height;
  final Widget child;

  const _Shell({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip
          .antiAlias, // Las imágenes no sobresalen de los bordes redondeados
      child: child,
    );
  }
}

// ─── Slideshow de fotogramas ──────────────────────────────────────────────────

/// Muestra los fotogramas del ejercicio en secuencia automática (cada 2 s).
/// El usuario también puede deslizar manualmente para ver cada fotograma.
/// Incluye indicadores de punto en la parte inferior cuando hay >1 fotograma.
class _ExerciseSlideshow extends StatefulWidget {
  final List<String>
      images; // Rutas de assets (ej. "assets/images/exercises/.../0.jpg")

  const _ExerciseSlideshow({required this.images});

  @override
  State<_ExerciseSlideshow> createState() => _ExerciseSlideshowState();
}

class _ExerciseSlideshowState extends State<_ExerciseSlideshow> {
  late final PageController
      _pageController; // Controla la página visible del PageView
  int _currentPage = 0; // Índice del fotograma visible actualmente
  Timer? _timer; // Timer de avance automático — cancelado en dispose

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Solo arranca el timer si hay más de un fotograma
    if (widget.images.length > 1) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Evita callbacks después de desmontar el widget
    _pageController.dispose();
    super.dispose();
  }

  /// Avanza automáticamente al siguiente fotograma cada 1 segundo (ciclo continuo).
  void _startAutoAdvance() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) %
          widget.images.length; // Vuelve al 0 al llegar al final
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // ── Visor de fotogramas ──────────────────────────────────────────
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (i) =>
              setState(() => _currentPage = i), // Actualiza el indicador
          itemBuilder: (_, i) => Image.asset(
            widget.images[i],
            fit: BoxFit.contain, // Muestra el ejercicio completo sin recortar
            errorBuilder: (_, __, ___) => const Center(
              // Si el asset falla (ruta incorrecta) muestra un icono de error en lugar de crashear
              child: Icon(Icons.broken_image_rounded,
                  color: AppColors.textSecondary, size: 40),
            ),
          ),
        ),

        // ── Indicadores de punto (solo con >1 fotograma) ─────────────────
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.images.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width:
                      isActive ? 16 : 6, // El activo es más ancho (tipo "pill")
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary // Azul para el activo
                        : AppColors.textSecondary
                            .withValues(alpha: 0.4), // Gris para los inactivos
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
