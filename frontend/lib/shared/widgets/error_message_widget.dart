import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart'; // Para el texto "Reintentar" localizado
import '../../core/theme/app_colors.dart';

/// Widget de error reutilizable.
/// Muestra un icono rojo, el mensaje de error y, opcionalmente, un botón de reintento.
/// Se usa cuando una llamada async falla (red, timeout, etc.).
class ErrorMessageWidget extends StatelessWidget {
  /// Mensaje de error localizado a mostrar al usuario.
  final String message;

  /// Función que se llama al pulsar "Reintentar".
  /// Si es null, el botón no se muestra (error sin acción posible).
  final VoidCallback? onRetry; // VoidCallback = función sin parámetros ni retorno

  const ErrorMessageWidget({
    super.key,
    required this.message, // El mensaje es obligatorio
    this.onRetry,          // El callback de reintento es opcional
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32), // Margen interior para que el contenido no toque los bordes
        child: Column(
          mainAxisSize: MainAxisSize.min, // Solo ocupa el espacio necesario
          children: [
            const Icon(
              Icons.error_outline_rounded, // Icono de error con bordes redondeados
              color: Colors.redAccent,     // Rojo suave para no ser agresivo
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center, // Centrado para mensajes de varias líneas
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5, // Interlineado — mejora la legibilidad
              ),
            ),
            if (onRetry != null) ...[ // Muestra el botón solo si se pasó un callback
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onRetry, // Llama a la función de reintento (normalmente _loadData())
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                label: Text(
                  LocaleManager.strings.errorRetry, // "Reintentar" / "Retry" según idioma
                  style: const TextStyle(color: AppColors.primary, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
