/// Datos de una sesión para el calendario de progreso.
/// Cada elemento del calendario semanal/mensual es un CalendarSessionModel.
/// Extraído de dashboard_model.dart porque ProgressScreen lo usa
/// de forma independiente al resto del dashboard.
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
