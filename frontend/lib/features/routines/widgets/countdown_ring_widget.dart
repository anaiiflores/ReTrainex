import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Anillo de cuenta atrás reutilizable.
/// [progress] va de 1.0 (lleno) a 0.0 (vacío).
/// [color] opcional: cuando se pasa, dibuja el arco en color sólido en lugar
/// del gradiente azul→cian por defecto.
class CountdownRingWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;

  const CountdownRingWidget({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 9,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RingPainter(
        progress: progress,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color? color;

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Pista de fondo
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (color != null) {
      arcPaint.color = color!;
    } else {
      arcPaint.shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    }

    canvas.drawArc(
      rect,
      -pi / 2,           // empieza desde arriba
      2 * pi * progress, // barre en sentido horario
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
