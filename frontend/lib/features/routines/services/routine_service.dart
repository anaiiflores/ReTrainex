import '../models/routine_model.dart';
import '../models/routine_detail_model.dart';
import '../../exercises/services/exercise_service.dart';

class RoutineService {
  // ── Mock data ─────────────────────────────────────────────────────────────
  // Sustituir los returns mock por llamadas reales cuando el backend esté listo.
  // Ejemplo: final response = await apiClient.get('/routines/weekly');

  static final List<RoutineModel> _mockRoutines = [
    RoutineModel(
      id: 'r1',
      day: 'LUNES',
      title: 'Movilidad de Hombro',
      minutes: 15,
      difficulty: 'BAJA',
      status: RoutineStatus.completed,
    ),
    RoutineModel(
      id: 'r2',
      day: 'MARTES',
      title: 'Fortalecimiento Escapular',
      minutes: 20,
      difficulty: 'MEDIA',
      status: RoutineStatus.completed,
    ),
    RoutineModel(
      id: 'r3',
      day: 'VIERNES',
      title: 'Estiramiento Pectoral',
      minutes: 10,
      difficulty: 'BAJA',
      status: RoutineStatus.today,
    ),
  ];

  // Los ejercicios de la sesión se obtienen del catálogo de ExerciseService,
  // evitando duplicar los datos en dos sitios.
  static final RoutineDetailModel _mockDetail = RoutineDetailModel(
    id: 'rd1',
    sessionId: 'KINETIC_RECOVERY',
    description:
        'SESIÓN: KINETIC_RECOVERY. Hoy nos enfocaremos en la movilidad '
        'articular y la reducción de la tensión en el manguito rotador. '
        'Realiza cada ejercicio con calma.',
    exercises: ExerciseService.mockExercises,
  );

  // ── Métodos públicos ──────────────────────────────────────────────────────

  Future<RoutineModel?> getTodaySession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockRoutines.firstWhere((r) => r.status == RoutineStatus.today);
    } catch (_) {
      return null;
    }
    // Reemplazar con:
    // final response = await apiClient.get('/routines/today');
    // return response != null ? RoutineModel.fromJson(response) : null;
  }

  Future<List<RoutineModel>> getWeeklyRoutines() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockRoutines;
    // Reemplazar con:
    // final response = await apiClient.get('/routines/weekly');
    // return (response as List).map((j) => RoutineModel.fromJson(j)).toList();
  }

  Future<RoutineDetailModel> getRoutineDetail(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockDetail;
    // Reemplazar con:
    // final response = await apiClient.get('/routines/$routineId/detail');
    // return RoutineDetailModel.fromJson(response);
  }
}
