import '../models/routine_model.dart'; // RoutineModel y RoutineStatus
import '../models/routine_detail_model.dart'; // RoutineDetailModel con lista de ejercicios
import '../../exercises/services/exercise_service.dart'; // Catálogo de ejercicios mock

/// Servicio de acceso a datos de rutinas semanales y detalle de sesión.
/// Actualmente usa datos mock; cada método indica cómo sustituirlos por llamadas reales.
class RoutineService {
  // ── Mock data ─────────────────────────────────────────────────────────────
  // `static final` → lista compartida entre instancias, creada una sola vez.
  // `const` no es posible aquí porque RoutineStatus no tiene constructor const
  // (es un enum, pero el problema es que la lista en sí puede mutar en teoría).
  static final List<RoutineModel> _mockRoutines = [
    RoutineModel(
      id: 'r1',
      day: 'LUNES',
      title: 'Movilidad de Hombro',
      minutes: 15,
      difficulty: 'BAJA',
      status: RoutineStatus.completed, // Ya completada — muestra tick verde
    ),
    RoutineModel(
      id: 'r2',
      day: 'MARTES',
      title: 'Fortalecimiento Escapular',
      minutes: 20,
      difficulty: 'MEDIA',
      status: RoutineStatus.today, // También completada
    ),
    RoutineModel(
      id: 'r3',
      day: 'VIERNES',
      title: 'Estiramiento Pectoral',
      minutes: 10,
      difficulty: 'BAJA',
      status:
          RoutineStatus.upcoming, // Toca hoy → resaltada con botón "INICIAR"
    ),
  ];

  /// Detalle mock de la sesión: reutiliza el catálogo de ExerciseService
  /// para no duplicar los datos del ejercicio en dos sitios.
  /// Es un getter (no `static final`) para que lea `ExerciseService.mockExercises`
  /// después de que ExerciseService.initialize() lo haya poblado en main().
  static RoutineDetailModel get _mockDetail => RoutineDetailModel(
        id: 'rd1',
        sessionId: 'KINETIC_RECOVERY', // Nombre de la sesión de tratamiento
        description:
            'SESIÓN: KINETIC_RECOVERY. Hoy nos enfocaremos en la movilidad '
            'articular y la reducción de la tensión en el manguito rotador. '
            'Realiza cada ejercicio con calma.',
        exercises: ExerciseService
            .mockExercises, // Lista de ejercicios del catálogo compartido
      );

  // ── Métodos públicos ──────────────────────────────────────────────────────

  /// Devuelve la rutina de hoy si existe, o null si no hay ninguna programada.
  /// `async` permite usar `await`; el `try/catch` atrapa `StateError` de `firstWhere`.
  Future<RoutineModel?> getTodaySession() async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Latencia simulada
    try {
      // `firstWhere` lanza StateError si no hay ninguna con status == today
      return _mockRoutines.firstWhere((r) => r.status == RoutineStatus.today);
    } catch (_) {
      return null; // No hay rutina hoy → devuelve null sin error
    }
    // TODO: Reemplazar con:
    // final response = await apiClient.get('/routines/today');
    // return response != null ? RoutineModel.fromJson(response) : null;
  }

  /// Devuelve la lista de rutinas de la semana actual (todas las programadas).
  Future<List<RoutineModel>> getWeeklyRoutines() async {
    await Future.delayed(
        const Duration(milliseconds: 600)); // Simula más latencia
    return _mockRoutines;
    // TODO: Reemplazar con:
    // final response = await apiClient.get('/routines/weekly');
    // return (response as List).map((j) => RoutineModel.fromJson(j)).toList();
  }

  /// Devuelve el detalle completo de una rutina por su [routineId].
  /// El mock ignora el ID y siempre devuelve el mismo detalle.
  Future<RoutineDetailModel> getRoutineDetail(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockDetail; // En producción se filtrarán los detalles por routineId
    // TODO: Reemplazar con:
    // final response = await apiClient.get('/routines/$routineId/detail');
    // return RoutineDetailModel.fromJson(response);
  }
}
