import 'package:flutter/material.dart'; // Necesario para usar Color y Colors

/// Paleta de colores centralizada de la app.
/// Todos los widgets usan estas constantes — si cambia un color aquí, cambia en toda la app.
/// Los valores son 'static const' porque pertenecen a la clase, no a instancias,
/// y son constantes de compilación (sin coste en tiempo de ejecución).
class AppColors {
  // ── Fondos ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0D14); // Fondo principal — negro azulado oscuro
  static const Color surface = Color(0xFF121826);    // Superficie elevada — ligeramente más claro que background
  static const Color card = Color(0xFF1A2233);       // Tarjetas — un tono más claro que surface

  // ── Colores de acción ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2F80FF);    // Azul principal — botones, iconos activos, bordes destacados
  static const Color secondary = Color(0xFF00C2FF);  // Cian secundario — acentos, gradientes, sesión completada

  // ── Texto ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;              // Texto principal — blanco puro
  static const Color textSecondary = Color(0xFF9AA4B2);       // Texto secundario — gris azulado para etiquetas y subtítulos

  // ── Bordes ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF263248);     // Borde estándar — separa tarjetas del fondo sin ser agresivo
}
