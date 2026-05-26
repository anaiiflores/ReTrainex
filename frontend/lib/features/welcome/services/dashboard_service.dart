import '../models/dashboard_model.dart'; // Modelos del dashboard
import '../../users/services/user_service.dart'; // Para obtener el nombre/fisio del usuario
import '../../routines/models/routine_model.dart'
    as r; // Alias `r` para evitar conflicto con RoutineStatus de dashboard
import '../../routines/services/routine_service.dart'; // Para obtener las rutinas de la semana

/// Servicio del dashboard de bienvenida.
/// Agrega datos de UserService y RoutineService para construir el DashboardModel.
class DashboardService {
  /// Devuelve los datos completos del dashboard del usuario autenticado.
  /// Endpoint real: GET /me/dashboard
  Future<DashboardModel> getDashboardData() async {
    // Pausa simulada de red (600 ms) antes de comenzar a procesar
    await Future.delayed(const Duration(milliseconds: 600));

    // Lanza ambas peticiones en paralelo para reducir el tiempo de espera total
    final userFuture = UserService().getUser(); // Carga el perfil del usuario
    final routinesFuture = RoutineService()
        .getWeeklyRoutines(); // Carga rutinas de la semana actual

    // Espera a que ambas completen
    final user = await userFuture;
    final routines = await routinesFuture;

    // Calcula el progreso semanal contando rutinas completadas en la semana actual
    final weeklyTotal =
        routines.length; // Total de rutinas planificadas esta semana
    final weeklyCompleted = routines
        .where((rt) => rt.status == r.RoutineStatus.completed)
        .length; // Cuántas están completadas

    // ── SIMULACIÓN ────────────────────────────────────────────────────────
    // Cambia `status` para probar distintos estados de la pantalla de bienvenida:
    //   RoutineStatus.none          → pantalla vacía (sin rutina asignada todavía)
    //   RoutineStatus.newAssignment → tarjeta "NUEVA ASIGNACIÓN" del fisio
    //   RoutineStatus.active        → dashboard completo con progreso y próxima sesión
    // ─────────────────────────────────────────────────────────────────────
    return DashboardModel(
      userName:
          'MARÍA', // Hardcodeado — en producción vendrá de `user.userName`
      status:
          RoutineStatus.active, // Estado activo: muestra el dashboard completo
      progressPercentage: 0, // 0% de progreso total (pendiente de backend real)
      completedSessions: 0, // Sesiones completadas en el tratamiento
      totalSessions: 10, // Total de sesiones planificadas en el tratamiento
      weeklyCompletedSessions:
          weeklyCompleted, // Calculado a partir de RoutineService
      weeklyTotalSessions: weeklyTotal, // Total semanal real
      hasUnreadNotification: false, // Sin notificaciones sin leer en este mock
      nextSession: const NextSessionModel(
        date: '27 MAY', // Fecha de la próxima sesión con el fisio
        time: '10:30 AM', // Hora de la cita
        durationMinutes: 15, // Duración estimada de la sesión
        type:
            'FISIOTERAPIA', // Tipo de sesión (con el fisio, no ejercicio propio)
      ),
      // Recordatorio personalizado usando el nombre del fisio del perfil de usuario
      reminder:
          'Mantén tu hidratación antes de la sesión con el Dr. ${user.physioName ?? 'tu fisioterapeuta'}.',
      // Los siguientes campos solo son relevantes cuando status == newAssignment:
      assignmentTitle:
          'Nuevo tratamiento de ejercicios', // Título de la nueva rutina asignada
      physioName: user.physioName, // Nombre del fisio que asignó la rutina
    );

    // TODO: Reemplazar con llamada real:
    // final response = await apiClient.get('/me/dashboard');
    // return DashboardModel.fromJson(response as Map<String, dynamic>);
  }

  /// Devuelve la lista de sesiones para el calendario de progreso.
  /// Cubre desde el primer día del mes anterior hasta el último del mes siguiente.
  /// Endpoint real: GET /me/calendar-sessions
  Future<List<CalendarSessionModel>> getCalendarSessions() async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Latencia simulada

    final now = DateTime.now();
    // `todayMidnight` normaliza la hora a 00:00:00 para comparaciones de fecha puras
    final todayMidnight = DateTime(now.year, now.month, now.day);

    // Calcula el lunes de la semana actual (weekday: 1=Lun, 7=Dom)
    final monday =
        todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
    final weekStart = monday;
    final weekEnd = weekStart.add(const Duration(days: 7)); // Domingo inclusive

    // Obtiene el estado real de las rutinas de esta semana para marcar correctamente completadas
    final weeklyRoutines = await RoutineService().getWeeklyRoutines();
    final completedDays =
        <int>{}; // Set de números de día (1=Lun…7=Dom) con sesión completada
    for (final rt in weeklyRoutines) {
      if (rt.status == r.RoutineStatus.completed) {
        completedDays.add(
            rt.weekday); // Guarda el día de la semana de cada rutina completada
      }
    }

    final sessions = <CalendarSessionModel>[]; // Lista resultado

    // Rango de fechas: del día 1 del mes anterior al último día del mes siguiente
    final start =
        DateTime(now.year, now.month - 1, 1); // Primer día del mes anterior
    final end = DateTime(now.year, now.month + 2,
        0); // Último día del mes siguiente (día 0 = último del mes anterior)

    // Itera día a día en el rango
    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      // Determina si el día cae en la semana actual
      final isCurrentWeek = !d.isBefore(weekStart) && d.isBefore(weekEnd);

      bool isCompleted;
      if (isCurrentWeek) {
        // Para la semana actual: usa el estado real de RoutineService
        isCompleted = completedDays.contains(d.weekday);
      } else {
        // Para semanas pasadas: asume completada si el día ya pasó
        // Para semanas futuras: siempre no completada (isBefore == false → completed = false)
        isCompleted = d.isBefore(todayMidnight);
      }

      // Solo añade sesión en los días que el usuario tiene rutina programada (Lun/Mié/Vie)
      if (d.weekday == DateTime.monday) {
        // weekday == 1
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Movilidad de Hombro',
          time: '10:00',
          durationMinutes: 15,
          completed: isCompleted,
        ));
      } else if (d.weekday == DateTime.wednesday) {
        // weekday == 3
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Fortalecimiento Escapular',
          time: '10:30',
          durationMinutes: 20,
          completed: isCompleted,
        ));
      } else if (d.weekday == DateTime.friday) {
        // weekday == 5
        sessions.add(CalendarSessionModel(
          date: d,
          title: 'Estiramiento Pectoral',
          time: '11:00',
          durationMinutes: 10,
          completed: isCompleted,
        ));
      }
      // El resto de días (Mar, Jue, Sáb, Dom) no tienen sesión → se omiten
    }
    return sessions;

    // TODO: Reemplazar con:
    // final response = await apiClient.get('/me/calendar-sessions');
    // return (response as List).map((j) => CalendarSessionModel.fromJson(j)).toList();
  }
}
