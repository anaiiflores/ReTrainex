/// Estado de la rutina del usuario en el dashboard.
/// Controla qué bloque de bienvenida se muestra en WelcomeIniScreen.
enum RoutineStatus {
  none,          // El usuario no tiene ninguna rutina asignada todavía
  newAssignment, // El fisio acaba de asignar una rutina nueva (se muestra card de presentación)
  active,        // Rutina en curso — se muestran progreso y acciones del día
}

/// Datos de una sesión para el calendario de progreso.
/// Cada elemento del calendario semanal/mensual es un CalendarSessionModel.
class CalendarSessionModel {
  final DateTime date;          // Fecha exacta de la sesión (año, mes, día)
  final String title;           // Nombre de la rutina de esa sesión
  final String time;            // Hora de inicio formateada ("10:30 AM")
  final int durationMinutes;    // Duración de la sesión en minutos
  final bool completed;         // true → sesión completada; false → perdida o pendiente

  const CalendarSessionModel({
    required this.date,
    required this.title,
    required this.time,
    required this.durationMinutes,
    required this.completed,
  });
}

/// Datos de la próxima sesión programada.
/// Se muestra en la tarjeta "Próxima sesión" del dashboard.
class NextSessionModel {
  final String date;           // Fecha formateada para mostrar ("15 OCT")
  final String time;           // Hora formateada ("10:30 AM")
  final int durationMinutes;   // Duración estimada en minutos
  final String type;           // Tipo de sesión ("FISIOTERAPIA", "EJERCICIO", etc.)

  const NextSessionModel({
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.type,
  });

  /// Crea un NextSessionModel a partir del JSON del backend.
  factory NextSessionModel.fromJson(Map<String, dynamic> json) {
    return NextSessionModel(
      date: json['date'] as String,
      time: json['time'] as String,
      durationMinutes: json['duration_minutes'] as int,
      type: json['type'] as String,
    );
  }

  /// Serializa el modelo para enviarlo al backend.
  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'duration_minutes': durationMinutes,
        'type': type,
      };
}

/// Modelo principal del dashboard de bienvenida.
/// Agrupa todos los datos que necesita WelcomeIniScreen para renderizarse.
class DashboardModel {
  final String userName;              // Nombre del usuario para el saludo ("¡Hola, MARÍA!")
  final RoutineStatus status;         // Estado actual de la rutina (controla qué bloque mostrar)
  final int progressPercentage;       // Progreso global del tratamiento (0–100%)
  final int completedSessions;        // Sesiones completadas en total
  final int totalSessions;            // Sesiones totales planificadas en el tratamiento
  final int weeklyCompletedSessions;  // Sesiones completadas esta semana
  final int weeklyTotalSessions;      // Sesiones planificadas esta semana
  final bool hasUnreadNotification;   // true → muestra el badge rojo en el icono de campana
  final NextSessionModel? nextSession; // null → no hay próxima sesión programada
  final String? reminder;             // Mensaje de recordatorio del fisio (null → sin recordatorio)

  // ── Campos adicionales solo para status == newAssignment ─────────────────
  final String? assignmentTitle; // Título de la nueva rutina asignada
  final String? physioName;      // Nombre del fisio que la asignó

  /// Fracción del progreso semanal (0.0–1.0) para la barra de progreso.
  /// Devuelve 0.0 si no hay sesiones planificadas (evita división por cero).
  double get weeklyProgress =>
      weeklyTotalSessions > 0 ? weeklyCompletedSessions / weeklyTotalSessions : 0.0;

  const DashboardModel({
    required this.userName,
    required this.status,
    this.progressPercentage = 0,      // Valor por defecto para nuevos usuarios
    this.completedSessions = 0,
    this.totalSessions = 0,
    this.weeklyCompletedSessions = 0,
    this.weeklyTotalSessions = 0,
    this.hasUnreadNotification = false,
    this.nextSession,
    this.reminder,
    this.assignmentTitle,
    this.physioName,
  });

  /// Crea un DashboardModel desde el JSON del backend.
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String; // Lee el estado como String ("active", "none", etc.)
    // Busca el valor del enum cuyo `.name` coincida con el String del JSON
    final status = RoutineStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => RoutineStatus.none, // Fallback seguro si el backend envía un valor desconocido
    );
    return DashboardModel(
      userName: json['user_name'] as String,
      status: status,
      progressPercentage: json['progress_percentage'] as int? ?? 0,    // ?? 0 → si es null usa 0
      completedSessions: json['completed_sessions'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      weeklyCompletedSessions: json['weekly_completed_sessions'] as int? ?? 0,
      weeklyTotalSessions: json['weekly_total_sessions'] as int? ?? 0,
      hasUnreadNotification: json['has_unread_notification'] as bool? ?? false,
      nextSession: json['next_session'] != null
          ? NextSessionModel.fromJson(
              json['next_session'] as Map<String, dynamic>) // Deserializa el objeto anidado
          : null,
      reminder: json['reminder'] as String?,
      assignmentTitle: json['assignment_title'] as String?,
      physioName: json['physio_name'] as String?,
    );
  }

  /// Serializa el modelo. Solo incluye campos opcionales si tienen valor.
  Map<String, dynamic> toJson() => {
        'user_name': userName,
        'status': status.name,                 // `.name` convierte el enum a String ("active")
        'progress_percentage': progressPercentage,
        'completed_sessions': completedSessions,
        'total_sessions': totalSessions,
        'weekly_completed_sessions': weeklyCompletedSessions,
        'weekly_total_sessions': weeklyTotalSessions,
        'has_unread_notification': hasUnreadNotification,
        if (nextSession != null) 'next_session': nextSession!.toJson(), // Solo si hay próxima sesión
        if (reminder != null) 'reminder': reminder,
        if (assignmentTitle != null) 'assignment_title': assignmentTitle,
        if (physioName != null) 'physio_name': physioName,
      };
}
