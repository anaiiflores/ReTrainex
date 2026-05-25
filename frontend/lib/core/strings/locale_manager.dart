import 'app_strings.dart';    // Clase abstracta con todas las claves de texto
import 'app_strings_en.dart'; // Implementación en inglés
import 'app_strings_es.dart'; // Implementación en español

/// Enum con los idiomas soportados por la app.
/// Añadir un nuevo idioma requiere: (1) añadir un valor aquí, (2) crear AppStringsXX,
/// (3) añadir un caso al switch de LocaleManager.strings.
enum AppLocale { es, en }

/// Gestor de idioma global — único punto de acceso al texto localizado.
///
/// Uso habitual en un widget:
///   LocaleManager.strings.loading   → devuelve "Cargando..." o "Loading..."
///   LocaleManager.setLocale(AppLocale.en)  → cambia el idioma en tiempo de ejecución
///
/// NOTA: No usa InheritedWidget ni ChangeNotifier porque el cambio de idioma
/// se gestiona con setState() en WelcomeIniScreen (raíz de la app).
class LocaleManager {
  /// Idioma activo. Privado (_) para que solo cambie a través de setLocale().
  static AppLocale _current = AppLocale.es; // Español por defecto al arrancar

  /// Getter público de solo lectura — expone el idioma actual sin permitir asignación directa.
  static AppLocale get current => _current;

  /// Devuelve el conjunto de strings para el idioma activo.
  /// El switch garantiza que siempre se devuelve una implementación concreta.
  static AppStrings get strings {
    switch (_current) {
      case AppLocale.en:
        return const AppStringsEn(); // Instancia constante → coste cero
      case AppLocale.es:
        return const AppStringsEs(); // Instancia constante → coste cero
    }
  }

  /// Cambia el idioma activo.
  /// Los widgets que leen LocaleManager.strings deben llamar a setState()
  /// después de este método para re-renderizarse con el nuevo idioma.
  static void setLocale(AppLocale locale) {
    _current = locale; // Actualiza el campo privado
  }
}
