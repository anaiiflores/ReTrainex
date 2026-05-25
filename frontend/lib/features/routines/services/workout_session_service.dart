/// Servicio para gestionar el estado de una sesión de ejercicio activa.
/// Registra el inicio, el progreso por ejercicio y el cierre de la sesión.
/// Preparado para conectarse al backend cuando la API esté disponible.
class WorkoutSessionService {
  /// ID de la sesión activa en el backend.
  /// null cuando no hay sesión en curso.
  String? _activeSessionId;

  // ── Tracking de duración ──────────────────────────────────────────────────
  // `static` → pertenece a la clase, no a la instancia.
  // Sobrevive entre instancias de WorkoutSessionService para que la duración
  // sea consistente aunque se cree una nueva instancia en otro widget.
  static DateTime? _sessionStartedAt; // Momento exacto en que el paciente pulsó INICIAR

  /// Registra el momento de inicio de la sesión para calcular la duración total.
  /// Se llama desde WorkoutPreparationScreen al confirmar el inicio.
  static void markStart() => _sessionStartedAt = DateTime.now();

  /// Segundos transcurridos desde que se llamó a `markStart()`.
  /// Se usa en WorkoutCompleteScreen para mostrar la duración real de la sesión.
  /// Devuelve 0 si no se ha marcado el inicio todavía.
  static int get elapsedSeconds {
    if (_sessionStartedAt == null) return 0; // Sin inicio marcado → duración cero
    return DateTime.now().difference(_sessionStartedAt!).inSeconds;
  }

  // ── Operaciones de sesión ─────────────────────────────────────────────────

  /// Inicia una sesión en el backend y almacena el ID localmente.
  /// Devuelve el ID de sesión creado (mock: ID con timestamp para que sea único).
  Future<String> startSession(String routineId) async {
    // TODO: Reemplazar con:
    // final response = await apiClient.post('/workout-sessions', {
    //   'session_id': routineId,
    //   'started_at': DateTime.now().toIso8601String(),
    // });
    // _activeSessionId = response['id'] as String;

    // Mock: genera un ID único usando el timestamp actual en milisegundos
    _activeSessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
    return _activeSessionId!; // '!' seguro: acabamos de asignarlo
  }

  /// Notifica al backend que el paciente terminó la cuenta atrás de preparación
  /// y va a comenzar a ejecutar el ejercicio [exerciseId].
  /// Se llama desde WorkoutPreparationScreen cuando el timer llega a cero.
  void onPreparationComplete(String exerciseId) {
    // TODO: Reemplazar con:
    // await apiClient.post(
    //   '/workout-sessions/$_activeSessionId/exercises/$exerciseId/start',
    //   {'started_at': DateTime.now().toIso8601String(), 'skipped': false},
    // );
  }

  /// Marca un ejercicio individual como completado en el backend.
  /// Se llama desde WorkoutExerciseScreen cuando termina el temporizador del ejercicio.
  Future<void> completeExercise(String exerciseId) async {
    // TODO: Reemplazar con:
    // await apiClient.patch(
    //   '/workout-sessions/$_activeSessionId/exercises/$exerciseId/complete',
    //   {'completed_at': DateTime.now().toIso8601String(), 'skipped': false},
    // );
  }

  /// Cierra la sesión completa cuando el paciente termina todos los ejercicios.
  /// Limpia el ID de sesión y el timestamp de inicio para que la próxima sesión empiece limpia.
  Future<void> completeSession() async {
    if (_activeSessionId == null) return; // Sin sesión activa → no hace nada
    // TODO: Reemplazar con:
    // await apiClient.patch('/workout-sessions/$_activeSessionId/complete', {
    //   'completed_at': DateTime.now().toIso8601String(),
    //   'status': 'completed',
    // });
    _activeSessionId = null;   // Limpia el ID de sesión
    _sessionStartedAt = null;  // Limpia el timestamp de inicio
  }
}
