import 'package:flutter/material.dart'; // CircularProgressIndicator, Column, Text, etc.
import '../../core/theme/app_colors.dart'; // AppColors.primary, AppColors.textSecondary

/// Widget reutilizable de carga.
/// Centra un spinner de progreso circular y, opcionalmente, un texto explicativo.
/// Se usa en cualquier pantalla mientras se espera una llamada async.
class LoadingWidget extends StatelessWidget {
  /// Texto que aparece bajo el spinner (por ejemplo "Cargando sesión...").
  /// Si es null, solo se muestra el spinner.
  final String? message;

  const LoadingWidget({super.key, this.message}); // message es opcional

  @override
  Widget build(BuildContext context) {
    return Center( // Centra el contenido tanto horizontal como verticalmente
      child: Column(
        mainAxisSize: MainAxisSize.min, // La columna solo ocupa el espacio de sus hijos
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary, // Anillo en azul de la app
            strokeWidth: 3,          // Grosor del anillo (por defecto es 4)
          ),
          if (message != null) ...[ // Spread condicional: añade los widgets solo si message no es null
            const SizedBox(height: 16), // Espacio entre el spinner y el texto
            Text(
              message!, // '!' es seguro porque ya verificamos que no es null arriba
              style: const TextStyle(
                color: AppColors.textSecondary, // Gris — no distrae del spinner
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
