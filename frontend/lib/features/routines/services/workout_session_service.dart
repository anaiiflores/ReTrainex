/// Servicio para gestionar el estado de una sesión de ejercicio activa.
/// Preparado para conectarse a la API cuando esté lista.
class WorkoutSessionService {
  String? _activeSessionId;

  // ── Tracking de duración (estático para sobrevivir entre instancias) ──────
  static DateTime? _sessionStartedAt;

  /// Registra el momento en que el paciente pulsa INICIAR.
  static void markStart() => _sessionStartedAt = DateTime.now();

  /// Segundos transcurridos desde que se llamó a markStart().
  static int get elapsedSeconds {
    if (_sessionStartedAt == null) return 0;
    return DateTime.now().difference(_sessionStartedAt!).inSeconds;
  }

  // ── Operaciones de sesión ─────────────────────────────────────────────────

  /// Inicia una sesión en el backend y almacena el ID localmente.
  Future<String> startSession(String routineId) async {
    // Reemplazar con:
    // final response = await apiClient.post('/workout-sessions', {
    //   'session_id': routineId,
    //   'started_at': DateTime.now().toIso8601String(),
    // });
    // _activeSessionId = response['id'] as String;
    _activeSessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
    return _activeSessionId!;
  }

  /// Llamado cuando termina la cuenta atrás de preparación de un ejercicio.
  void onPreparationComplete(String exerciseId) {
    // Reemplazar con:
    // await apiClient.post(
    //   '/workout-sessions/$_activeSessionId/exercises/$exerciseId/start',
    //   {'started_at': DateTime.now().toIso8601String(), 'skipped': false},
    // );
  }

  /// Marca un ejercicio individual como completado.
  Future<void> completeExercise(String exerciseId) async {
    // Reemplazar con:
    // await apiClient.patch(
    //   '/workout-sessions/$_activeSessionId/exercises/$exerciseId/complete',
    //   {'completed_at': DateTime.now().toIso8601String(), 'skipped': false},
    // );
  }

  /// Cierra la sesión completa cuando el paciente termina todos los ejercicios.
  Future<void> completeSession() async {
    if (_activeSessionId == null) return;
    // Reemplazar con:
    // await apiClient.patch('/workout-sessions/$_activeSessionId/complete', {
    //   'completed_at': DateTime.now().toIso8601String(),
    //   'status': 'completed',
    // });
    _activeSessionId = null;
    _sessionStartedAt = null;
  }
}
