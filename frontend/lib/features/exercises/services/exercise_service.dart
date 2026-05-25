import '../models/exercise_detail_model.dart';

class ExerciseService {
  // Catálogo de ejercicios disponibles en la app.
  // Sustituir por llamada real cuando el backend esté listo.
  static final List<ExerciseModel> mockExercises = const [
    ExerciseModel(
      id: 'e1',
      name: 'Rotación de hombros',
      series: 3,
      reps: 10,
      minutes: 0,
    ),
    ExerciseModel(
      id: 'e2',
      name: 'Estiramiento Pectoral',
      minutes: 2,
    ),
    ExerciseModel(
      id: 'e3',
      name: 'Rotación Interna',
      series: 3,
      reps: 15,
      minutes: 0,
    ),
    ExerciseModel(
      id: 'e4',
      name: 'Isométrico Escapular',
      minutes: 5,
    ),
  ];

  /// Devuelve el detalle de un ejercicio por su [id].
  Future<ExerciseModel> getExerciseDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockExercises.firstWhere((e) => e.id == id);
    // Reemplazar con:
    // final response = await apiClient.get('/exercises/$id');
    // return ExerciseModel.fromJson(response);
  }
}
