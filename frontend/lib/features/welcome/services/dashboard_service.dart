import '../models/dashboard_model.dart';

class DashboardService {
  /// Endpoint real: GET /me/dashboard
  /// Devuelve nombre, estado de rutina, progreso y próxima sesión.
  Future<DashboardModel> getDashboardData() async {
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
        date: '20 OCT',
        time: '10:30 AM',
        durationMinutes: 15,
        type: 'FISIOTERAPIA',
      ),
      reminder: 'Mantén tu hidratación antes de la sesión con el Dr. Pérez.',
      // Activos solo cuando status == newAssignment:
      assignmentTitle: 'Nuevo tratamiento de ejercicios',
      physioName: 'Dr. Pérez',
    );

    // Reemplazar con llamada real:
    // final response = await apiClient.get('/me/dashboard');
    // return DashboardModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<CalendarSessionModel>> getCalendarSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final today = DateTime.now();
    final sessions = <CalendarSessionModel>[];
    final start = DateTime(today.year, today.month - 1, 1);
    final end = DateTime(today.year, today.month + 2, 0);

    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      if (d.weekday == DateTime.monday) {
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Movilidad de Hombro',
          time: '10:00',
          durationMinutes: 15,
          completed: d.isBefore(today),
        ));
      } else if (d.weekday == DateTime.wednesday) {
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Fortalecimiento Escapular',
          time: '10:30',
          durationMinutes: 20,
          completed: d.isBefore(today),
        ));
      } else if (d.weekday == DateTime.friday) {
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Estiramiento Pectoral',
          time: '11:00',
          durationMinutes: 10,
          completed: d.isBefore(today),
        ));
      }
    }
    return sessions;
    // Reemplazar con:
    // final response = await apiClient.get('/me/calendar-sessions');
    // return (response as List).map((j) => CalendarSessionModel.fromJson(j)).toList();
  }
}
