/// Datos de la próxima sesión programada.
/// Se muestra en la tarjeta "Próxima sesión" del dashboard.
/// Extraído de dashboard_model.dart para que DashboardModel y sus
/// dependencias puedan importarlo de forma independiente.
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
