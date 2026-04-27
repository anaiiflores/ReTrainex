import '../models/dashboard_model.dart';

class DashboardService {
  /// Endpoint real: GET /me/dashboard
  /// Devuelve nombre, estado de rutina, progreso y próxima sesión.
  Future<DashboardModel> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 600));

    // ── SIMULACIÓN ────────────────────────────────────────────────────────
    // Cambia `status` para simular distintos estados de la app:
    //   RoutineStatus.none          → pantalla vacía (sin rutina asignada)
    //   RoutineStatus.newAssignment → tarjeta "NUEVA ASIGNACIÓN" del fisio
    //   RoutineStatus.active        → dashboard con progreso y próxima sesión
    // ─────────────────────────────────────────────────────────────────────
    return DashboardModel(
      userName: 'MARÍA',
      status: RoutineStatus.active,
      progressPercentage: 0,
      completedSessions: 0,
      totalSessions: 10,
      hasUnreadNotification: false,
      nextSession: const NextSessionModel(
        date: '15 OCT',
        time: '10:30 AM',
        durationMinutes: 15,
        type: 'FISIOTERAPIA',
      ),
      reminder:
          'Mantén tu hidratación antes de la sesión con el Dr. Pérez.',
      // Activos solo cuando status == newAssignment:
      assignmentTitle: 'Nuevo tratamiento de ejercicios',
      physioName: 'Dr. Pérez',
    );

    // Reemplazar con llamada real:
    // final response = await apiClient.get('/me/dashboard');
    // return DashboardModel.fromJson(response as Map<String, dynamic>);
  }
}
