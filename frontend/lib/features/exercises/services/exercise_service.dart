import '../models/exercise_detail_model.dart'; // Importa el modelo que este servicio gestiona

/// Servicio de acceso a datos de ejercicios.
/// Por ahora usa datos mock estáticos; cuando el backend esté listo
/// se reemplazarán los métodos por llamadas HTTP reales.
class ExerciseService {
  /// Catálogo estático de ejercicios de demostración.
  /// `static` → pertenece a la clase, no a la instancia (un solo catálogo compartido).
  /// `final` → la referencia a la lista no puede cambiar tras la asignación.
  /// `const [...]` → la lista y todos sus elementos son constantes de compilación
  ///   (posible porque ExerciseModel tiene constructor `const`).
  static final List<ExerciseModel> mockExercises = const [
    ExerciseModel(
      id: 'e1',               // Identificador único para buscar este ejercicio
      name: 'Rotación de hombros', // Nombre legible mostrado en la UI
      series: 3,              // 3 series de 10 repeticiones
      reps: 10,               // Repeticiones por serie
      minutes: 0,             // 0 → no es ejercicio de mantenimiento por tiempo
    ),
    ExerciseModel(
      id: 'e2',
      name: 'Estiramiento Pectoral',
      minutes: 2,             // Solo tiene duración: 2 minutos de mantenimiento (sin series/reps)
    ),
    ExerciseModel(
      id: 'e3',
      name: 'Rotación Interna',
      series: 3,              // 3 series de 15 repeticiones
      reps: 15,
      minutes: 0,
    ),
    ExerciseModel(
      id: 'e4',
      name: 'Isométrico Escapular',
      minutes: 5,             // Ejercicio isométrico: mantener posición durante 5 minutos
    ),
  ];

  /// Devuelve el detalle completo de un ejercicio buscándolo por su [id].
  /// `async` → permite usar `await` dentro; retorna automáticamente un `Future`.
  /// `Future<ExerciseModel>` → la llamada es asíncrona, el resultado llega más tarde.
  Future<ExerciseModel> getExerciseDetail(String id) async {
    // Simula la latencia de red de una llamada real al backend (400 ms).
    // `await` pausa esta función hasta que el Future complete, sin bloquear el hilo UI.
    await Future.delayed(const Duration(milliseconds: 400));

    // Busca el primer ejercicio cuyo id coincida.
    // `firstWhere` lanza StateError si no hay coincidencia → en producción añadir `orElse`.
    return mockExercises.firstWhere((e) => e.id == id);

    // TODO: Reemplazar con llamada real al backend:
    // final response = await apiClient.get('/exercises/$id');
    // return ExerciseModel.fromJson(response);
  }
}
