import 'package:flutter/services.dart'; // rootBundle + AssetManifest
import '../models/exercise_detail_model.dart'; // Importa el modelo que este servicio gestiona

/// Servicio de acceso a datos de ejercicios.
/// Por ahora usa datos mock estáticos; cuando el backend esté listo
/// se reemplazarán los métodos por llamadas HTTP reales.
class ExerciseService {
  // ── Catálogo mock ─────────────────────────────────────────────────────────

  /// Catálogo de ejercicios de demostración.
  /// Se rellena en [initialize]; hasta entonces está vacío.
  /// No es `const` ni `final` porque se asigna de forma asíncrona.
  static List<ExerciseModel> mockExercises = [];

  // ── Inicialización ────────────────────────────────────────────────────────

  /// Lee el AssetManifest del bundle y puebla [mockExercises] con imágenes reales.
  /// Debe llamarse UNA VEZ en main(), justo antes de runApp().
  ///
  /// Ejemplo en main.dart:
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await ExerciseService.initialize();
  ///   runApp(const ReTrainexApp());
  static Future<void> initialize() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    mockExercises = [
      ExerciseModel(
        id: 'e1',
        name: 'Círculos con los Hombros hacia Atrás',
        series: 3,
        reps: 10,
        imageAssets: await _frames(manifest, 'Círculos con los Hombros hacia Atrás'),
        restAfterSeconds: 20,
      ),
      ExerciseModel(
        id: 'e2',
        name: 'Abducción de Hombros',
        series: 3,
        reps: 12,
        imageAssets: await _frames(manifest, 'Abducción de Hombros'),
        restAfterSeconds: 20,
      ),
      ExerciseModel(
        id: 'e3',
        name: 'Rotación Externa-Interna en Prono',
        series: 3,
        reps: 15,
        imageAssets: await _frames(manifest, 'Rotación Externa-Interna en Prono'),
        restAfterSeconds: 15,
      ),
      ExerciseModel(
        id: 'e4',
        name: 'Retracción Escapular',
        minutes: 5,
        imageAssets: await _frames(manifest, 'Retracción Escapular'),
      ),
    ];
  }

  // ── Utilidad de rutas ─────────────────────────────────────────────────────

  /// Devuelve las rutas de asset de todos los fotogramas del ejercicio cuyo
  /// nombre es [exerciseName], ordenados numéricamente (0.jpg, 1.jpg, 2.jpg…).
  ///
  /// La carpeta se deriva automáticamente: mayúsculas + espacios → '_'.
  ///   "Abducción de Hombros" → "ABDUCCIÓN_DE_HOMBROS"
  ///
  /// Usa [manifest] para contar los ficheros sin tener que pasar el número a mano.
  static Future<List<String>> _frames(
      AssetManifest manifest, String exerciseName) async {
    // Convierte el nombre del ejercicio al formato de carpeta
    final folder = exerciseName.toUpperCase().replaceAll(' ', '_');
    final prefix = 'assets/images/exercises/$folder/';
    final images = manifest
        .listAssets()
        .where((path) => path.startsWith(prefix))
        .toList()
      ..sort((a, b) {
        // Ordena por el número del fichero (0, 1, 2…) en lugar de alfabéticamente
        // para que no haya problemas si algún día hay más de 9 fotogramas.
        final na = int.tryParse(a.split('/').last.split('.').first) ?? 0;
        final nb = int.tryParse(b.split('/').last.split('.').first) ?? 0;
        return na.compareTo(nb);
      });
    return images;
  }

  // ── Métodos públicos ──────────────────────────────────────────────────────

  /// Devuelve el detalle completo de un ejercicio buscándolo por su [id].
  Future<ExerciseModel> getExerciseDetail(String id) async {
    // Simula la latencia de red de una llamada real al backend (400 ms)
    await Future.delayed(const Duration(milliseconds: 400));

    // Busca el primer ejercicio cuyo id coincida.
    // `firstWhere` lanza StateError si no hay coincidencia → en producción añadir `orElse`.
    return mockExercises.firstWhere((e) => e.id == id);

    // Reemplazar con llamada real al backend:
    // final response = await apiClient.get('/exercises/$id');
    // return ExerciseModel.fromJson(response);
  }
}
