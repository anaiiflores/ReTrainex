import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ── Gradient button (acción principal) ───────────────────────────────────────
// Uso recomendado: botones CTA como "VER DETALLES", "EMPEZAR".
// El gradiente azul→cian es la identidad visual de la app.

/// Botón con degradado de color de izquierda a derecha.
/// Requiere un truco: ElevatedButton con fondo transparente encima de un
/// DecoratedBox con el gradiente, porque ElevatedButton no soporta gradiente nativamente.
class AppGradientButton extends StatelessWidget {
  final String label;          // Texto del botón
  final VoidCallback? onPressed; // null deshabilita el botón visualmente
  final IconData? icon;        // Icono opcional a la izquierda del texto
  final double height;         // Alto del botón (por defecto 52px)
  final double borderRadius;   // Radio de las esquinas (por defecto 14px)
  final Color textColor;       // Color del texto (por defecto blanco)

  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.borderRadius = 14,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupa todo el ancho disponible
      height: height,
      child: DecoratedBox( // Capa de decoración que no interfiere con el hit-testing
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary], // Azul → Cian
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,   // Sin fondo propio — el gradiente lo proporciona DecoratedBox
            foregroundColor: textColor,             // Color de texto e iconos
            shadowColor: Colors.transparent,        // Sin sombra — diseño plano
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius)),
            elevation: 0, // Sin elevación
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // La fila ocupa solo el espacio del contenido
            children: [
              if (icon != null) ...[ // Muestra el icono solo si se pasó uno
                Icon(icon, size: 20),
                const SizedBox(width: 8), // Separación entre icono y texto
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5, // Espaciado de letras para el estilo HUD
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Solid button (acción confirmación) ───────────────────────────────────────
// Uso recomendado: "INICIAR", "VOLVER AL INICIO", acciones definitivas.
// Color sólido en lugar de gradiente para mayor peso visual.

/// Botón sólido de un solo color.
/// Permite personalizar el color para variantes (peligro, éxito, etc.).
class AppSolidButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final Color? color; // null → usa AppColors.primary por defecto

  const AppSolidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
    this.borderRadius = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary; // Si no se pasa color, usa el primario
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,                          // Fondo del color elegido
          disabledBackgroundColor: AppColors.border,    // Gris cuando está deshabilitado
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Outlined button (acción secundaria) ──────────────────────────────────────
// Uso recomendado: "OMITIR PREPARACIÓN", "OMITIR DESCANSO".
// Sin relleno — acción menos prominente que los botones sólido y gradiente.

/// Botón con solo borde visible, sin relleno.
/// Comunica "acción disponible pero no la principal".
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final Color? borderColor;      // null → usa AppColors.border
  final Color? foregroundColor;  // null → blanco

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.borderRadius = 14,
    this.borderColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.border; // Color del borde
    final fg = foregroundColor ?? Colors.white;     // Color del texto e iconos
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: border, width: 1.5), // Borde con 1.5px de grosor
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18), // Icono ligeramente más pequeño que en los otros botones
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
