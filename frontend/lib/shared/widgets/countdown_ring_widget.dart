import 'dart:math'; // pi — necesario para calcular el ángulo de inicio y el barrido del arco
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Anillo de cuenta atrás reutilizable.
/// [progress] va de 1.0 (anillo lleno) a 0.0 (anillo vacío).
/// [color] opcional: color sólido del arco. Si no se pasa, usa el gradiente azul→cian.
/// Se usa en WorkoutPreparationScreen, WorkoutExerciseScreen y WorkoutRestScreen.
class CountdownRingWidget extends StatelessWidget {
  final double progress;    // Fracción del arco a dibujar (0.0–1.0)
  final double size;        // Diámetro del anillo en píxeles lógicos (por defecto 300)
  final double strokeWidth; // Grosor del trazo del arco (por defecto 12)
  final Color? color;       // Color sólido opcional del arco activo

  const CountdownRingWidget({
    super.key,
    required this.progress,
    this.size = 300,
    this.strokeWidth = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(                  // Widget que delega el pintado a un CustomPainter
      size: Size(size, size),            // Tamaño del lienzo
      painter: _RingPainter(            // Pintor personalizado que dibuja el anillo
        progress: progress,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

/// CustomPainter que dibuja el anillo de progreso.
/// Privado (_) porque solo lo usa CountdownRingWidget en este archivo.
class _RingPainter extends CustomPainter {
  final double progress;    // Fracción 0.0–1.0
  final double strokeWidth;
  final Color? color;       // Null = usar gradiente

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2); // Centro geométrico del lienzo
    final radius = (size.width - strokeWidth) / 2;          // Radio que deja margen para el trazo

    // ── Pista de fondo ────────────────────────────────────────────────────
    // Círculo completo gris que sirve de "carril" vacío
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border        // Gris del tema
        ..style = PaintingStyle.stroke    // Solo el contorno, sin relleno
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return; // Si progress == 0, no dibujar el arco activo

    // ── Arco activo ───────────────────────────────────────────────────────
    // Rectángulo que enmarca el círculo — necesario para drawArc
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Extremos redondeados del arco

    if (color != null) {
      arcPaint.color = color!; // Color sólido si se especificó
    } else {
      // Gradiente lineal azul→cian que se mapea sobre el cuadrado que enmarca el círculo
      arcPaint.shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    }

    canvas.drawArc(
      rect,
      -pi / 2,           // Ángulo de inicio: -90° = arriba (las 12 en punto)
      2 * pi * progress, // Ángulo de barrido: fracción del círculo completo (2π = 360°)
      false,             // useCenter: false → arco abierto, sin líneas al centro
      arcPaint,
    );
  }

  @override
  // Flutter llama a shouldRepaint() antes de redibujar.
  // Devolver true solo cuando cambia progress o color evita repaints innecesarios.
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
