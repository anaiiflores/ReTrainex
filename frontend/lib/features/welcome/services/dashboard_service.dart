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

    // Lanza las tres peticiones en paralelo para reducir el tiempo de espera total
    final userFuture         = UserService().getUser();
    final routinesFuture     = RoutineService().getWeeklyRoutines();
    final todaySessionFuture = RoutineService().getTodaySession();

    final user         = await userFuture;
    final routines     = await routinesFuture;
    final todaySession = await todaySessionFuture;

    // Calcula el progreso semanal contando rutinas completadas en la semana actual
    final weeklyTotal     = routines.length;
    final weeklyCompleted = routines
        .where((rt) => rt.status == r.RoutineStatus.completed)
        .length;

    // ── Próxima sesión ─────────────────────────────────────────────────────
    // Solo se muestra cuando HOY NO es día de sesión.
    // Si todaySession != null el usuario ya tiene su sesión hoy → no necesita saber cuándo es la próxima.
    // Si todaySession == null buscamos la rutina no completada más cercana y calculamos su fecha real.
    NextSessionModel? nextSession;
    if (todaySession == null) {
      final today        = DateTime.now();
      final todayWeekday = today.weekday; // 1 = lunes … 7 = domingo

      int? minDaysAhead;
      r.RoutineModel? nextRoutine;

      for (final rt in routines) {
        if (rt.status == r.RoutineStatus.completed) continue; // Las completadas ya no cuentan

        // Días que quedan hasta el día de la semana de esta rutina
        int daysAhead = rt.weekday - todayWeekday;
        if (daysAhead <= 0) daysAhead += 7; // Si ya pasó (o es hoy sin status "today") → siguiente semana

        if (minDaysAhead == null || daysAhead < minDaysAhead) {
          minDaysAhead = daysAhead;
          nextRoutine  = rt;
        }
      }

      if (nextRoutine != null && minDaysAhead != null) {
        final nextDate = today.add(Duration(days: minDaysAhead));

        // Abreviaturas de mes en mayúsculas para el formato "27 MAY"
        // Hardcodeadas en español; en producción vendrán localizadas del backend
        const monthAbbr = [
          'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
          'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
        ];

        nextSession = NextSessionModel(
          date:            '${nextDate.day} ${monthAbbr[nextDate.month - 1]}',
          time:            '10:30 AM',              // Hora mock — vendrá del backend
          durationMinutes: nextRoutine.minutes,      // Duración real de esa rutina
          type:            'EJERCICIO',
        );
      }
    }
    // Si todaySession != null → nextSession queda null y no se renderiza la tarjeta

    // ── SIMULACIÓN ────────────────────────────────────────────────────────
    // Cambia `status` para probar distintos estados de la pantalla de bienvenida:
    //   RoutineStatus.none          → pantalla vacía (sin rutina asignada todavía)
    //   RoutineStatus.newAssignment → tarjeta "NUEVA ASIGNACIÓN" del fisio
    //   RoutineStatus.active        → dashboard completo con progreso y próxima sesión
    // ─────────────────────────────────────────────────────────────────────
    return DashboardModel(
      userName:                'MARÍA', // Hardcodeado — en producción vendrá de `user.userName`
      status:                  RoutineStatus.active,
      progressPercentage:      0,
      completedSessions:       0,
      totalSessions:           10,
      weeklyCompletedSessions: weeklyCompleted,
      weeklyTotalSessions:     weeklyTotal,
      hasUnreadNotification:   false,
      nextSession:             nextSession, // null si hoy es día de sesión; computed si no
      reminder:
          'Mantén tu hidratación antes de la sesión con el Dr. ${user.physioName ?? 'tu fisioterapeuta'}.',
      assignmentTitle: 'Nuevo tratamiento de ejercicios',
      physioName:      user.physioName,
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
