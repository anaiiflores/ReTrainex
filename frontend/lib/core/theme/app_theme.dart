import 'package:flutter/material.dart'; // ThemeData, Brightness, ColorScheme, etc.
import 'app_colors.dart'; // Paleta de colores de la app

/// Configuración global del tema visual.
/// Usar un getter estático (no un constructor) permite acceder al tema con
/// AppTheme.darkTheme sin crear una instancia de la clase.
class AppTheme {
  /// Devuelve el ThemeData oscuro que se aplica a toda la app.
  /// MaterialApp recibe este valor en su parámetro 'theme:'.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark, // Indica a Material que use iconos y textos en tono claro

      scaffoldBackgroundColor: AppColors.background, // Color de fondo por defecto de todos los Scaffold

      colorScheme: const ColorScheme.dark( // Define la paleta de colores del sistema de Material 3
        primary: AppColors.primary,     // Color principal (botones, selecciones)
        secondary: AppColors.secondary, // Color secundario (acentos)
        surface: AppColors.surface,     // Fondo de superficies elevadas (cards, dialogs)
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background, // AppBar con el mismo fondo que el Scaffold
        elevation: 0,                          // Sin sombra — diseño plano
        centerTitle: true,                     // Títulos centrados por defecto en todas las AppBar
      ),

      // cardTheme desactivado — se estiliza manualmente en cada widget para mayor control:
      /*cardTheme: CardTheme(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ), */

      inputDecorationTheme: InputDecorationTheme( // Estilo por defecto de todos los TextFormField / TextField
        filled: true,                              // Fondo relleno en lugar de solo borde inferior
        fillColor: AppColors.surface,              // Color del relleno
        border: OutlineInputBorder(                // Borde con esquinas redondeadas — estado neutro
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(         // Borde cuando el campo está habilitado pero no enfocado
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(         // Borde cuando el campo está activo (teclado abierto)
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary), // Azul para indicar foco
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary), // Etiqueta en gris
      ),

      elevatedButtonTheme: ElevatedButtonThemeData( // Estilo por defecto de todos los ElevatedButton
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,         // Fondo azul
          foregroundColor: Colors.white,               // Texto e iconos blancos
          minimumSize: const Size(double.infinity, 52), // Ancho completo, 52px de alto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),   // Esquinas redondeadas uniformes
          ),
        ),
      ),

      textTheme: const TextTheme( // Estilos base de texto aplicados automáticamente
        bodyMedium: TextStyle(color: AppColors.textPrimary),   // Texto de cuerpo principal → blanco
        bodySmall: TextStyle(color: AppColors.textSecondary),  // Texto pequeño/secundario → gris
      ),

      useMaterial3: true, // Activa Material Design 3 (componentes y transiciones actualizados)
    );
  }
}
