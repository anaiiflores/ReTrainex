import '../models/dashboard_model.dart';
import '../../profile/services/user_service.dart';
import '../../routines/models/routine_model.dart' as r;
import '../../routines/services/routine_service.dart';

class DashboardService {
  /// Endpoint real: GET /me/dashboard
  /// Devuelve nombre, estado de rutina, progreso y próxima sesión.
  Future<DashboardModel> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final userFuture = UserService().getUser();
    final routinesFuture = RoutineService().getWeeklyRoutines();
    final user = await userFuture;
    final routines = await routinesFuture;

    final weeklyTotal = routines.length;
    final weeklyCompleted =
        routines.where((rt) => rt.status == r.RoutineStatus.completed).length;

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
      weeklyCompletedSessions: weeklyCompleted,
      weeklyTotalSessions: weeklyTotal,
      hasUnreadNotification: false,
      nextSession: const NextSessionModel(
        date: '20 OCT',
        time: '10:30 AM',
        durationMinutes: 15,
        type: 'FISIOTERAPIA',
      ),
      reminder:
          'Mantén tu hidratación antes de la sesión con el Dr. ${user.physioName ?? 'tu fisioterapeuta'}.',
      // Activos solo cuando status == newAssignment:
      assignmentTitle: 'Nuevo tratamiento de ejercicios',
      physioName: user.physioName,
    );

    // Reemplazar con llamada real:
    // final response = await apiClient.get('/me/dashboard');
    // return DashboardModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<CalendarSessionModel>> getCalendarSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final monday = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
    final weekStart = monday;
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Para la semana actual, usa el RoutineStatus real
    final weeklyRoutines = await RoutineService().getWeeklyRoutines();
    final completedDays = <int>{};
    for (final rt in weeklyRoutines) {
      if (rt.status == r.RoutineStatus.completed) {
        completedDays.add(_weekdayFromDayName(rt.day));
      }
    }

    final sessions = <CalendarSessionModel>[];
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month + 2, 0);

    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      final isCurrentWeek = !d.isBefore(weekStart) && d.isBefore(weekEnd);
      bool isCompleted;
      if (isCurrentWeek) {
        isCompleted = completedDays.contains(d.weekday);
      } else {
        isCompleted = d.isBefore(todayMidnight);
      }

      if (d.weekday == DateTime.monday) {
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Movilidad de Hombro',
          time: '10:00',
          durationMinutes: 15,
          completed: isCompleted,
        ));
      } else if (d.weekday == DateTime.wednesday) {
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Fortalecimiento Escapular',
          time: '10:30',
          durationMinutes: 20,
          completed: isCompleted,
        ));
      } else if (d.weekday == DateTime.friday) {
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Estiramiento Pectoral',
          time: '11:00',
          durationMinutes: 10,
          completed: isCompleted,
        ));
      }
    }
    return sessions;
    // Reemplazar con:
    // final response = await apiClient.get('/me/calendar-sessions');
    // return (response as List).map((j) => CalendarSessionModel.fromJson(j)).toList();
  }

  int _weekdayFromDayName(String day) {
    switch (day.toUpperCase()) {
      case 'LUNES': return DateTime.monday;
      case 'MARTES': return DateTime.tuesday;
      case 'MIÉRCOLES': return DateTime.wednesday;
      case 'JUEVES': return DateTime.thursday;
      case 'VIERNES': return DateTime.friday;
      case 'SÁBADO': return DateTime.saturday;
      case 'DOMINGO': return DateTime.sunday;
      default: return -1;
    }
  }
}
