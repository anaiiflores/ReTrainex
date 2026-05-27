import '../models/exercise_detail_model.dart'; // Importa el modelo que este servicio gestiona

/// Servicio de acceso a datos de ejercicios.
/// Por ahora usa datos mock estáticos; cuando el backend esté listo
/// se reemplazarán los métodos por llamadas HTTP reales.
class ExerciseService {
  // ── Utilidad de rutas ─────────────────────────────────────────────────────

  /// Genera la lista de rutas de assets para los fotogramas de un ejercicio.
  /// [folder] es el nombre exacto de la carpeta en assets/images/exercises/.
  /// [count] es el número de imágenes (0.jpg, 1.jpg, … count-1.jpg).
  static List<String> _frames(String folder, int count) => List.generate(
        count,
        (i) => 'assets/images/exercises/$folder/$i.jpg',
      );

  // ── Catálogo mock ─────────────────────────────────────────────────────────

  /// Catálogo estático de ejercicios de demostración con imágenes reales.
  /// `static final` → pertenece a la clase, no a la instancia (un solo catálogo compartido).
  static final List<ExerciseModel> mockExercises = [
    ExerciseModel(
      id: 'e1',
      name: 'Círculos con los Hombros hacia Atrás',
      series: 3,
      reps: 10,
      imageAssets: _frames('CÍRCULOS_CON_LOS_HOMBROS_HACIA_ATRÁS', 3), // 3 fotogramas
      restAfterSeconds: 20,
    ),
    ExerciseModel(
      id: 'e2',
      name: 'Abducción de Hombros',
      series: 3,
      reps: 12,
      imageAssets: _frames('ABDUCCIÓN_DE_HOMBROS', 2), // 2 fotogramas
      restAfterSeconds: 20,
    ),
    ExerciseModel(
      id: 'e3',
      name: 'Rotación Externa-Interna en Prono',
      series: 3,
      reps: 15,
      imageAssets: _frames('ROTACIÓN_EXTERNA-INTERNA_EN_PRONO', 2), // 2 fotogramas
      restAfterSeconds: 15,
    ),
    ExerciseModel(
      id: 'e4',
      name: 'Retracción Escapular',
      minutes: 5, // Ejercicio isométrico: mantener posición durante 5 minutos
      imageAssets: _frames('RETRACCIÓN_ESCAPULAR', 1), // 1 fotograma (posición de mantenimiento)
    ),
  ];

  // ── Métodos públicos ──────────────────────────────────────────────────────

  /// Devuelve el detalle completo de un ejercicio buscándolo por su [id].
  Future<ExerciseModel> getExerciseDetail(String id) async {
    // Simula la latencia de red de una llamada real al backend (400 ms)
    await Future.delayed(const Duration(milliseconds: 400));

    // Busca el primer ejercicio cuyo id coincida.
    // `firstWhere` lanza StateError si no hay coincidencia → en producción añadir `orElse`.
    return mockExercises.firstWhere((e) => e.id == id);

    // TODO: Reemplazar con llamada real al backend:
    // final response = await apiClient.get('/exercises/$id');
    // return ExerciseModel.fromJson(response);
  }
}
