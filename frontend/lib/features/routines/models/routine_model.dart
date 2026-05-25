/// Estados posibles de una rutina dentro de la semana del paciente.
/// Controla el aspecto visual de la tarjeta en RoutinesListScreen.
enum RoutineStatus {
  completed, // Ya realizada este ciclo → tick verde, no se puede iniciar
  today,     // Toca hoy → resaltada en azul, botón "INICIAR" visible
  upcoming,  // Día futuro → bloqueada con icono de candado
}

/// Representa una rutina asignada a un día concreto de la semana.
/// Cada elemento de la lista semanal en RoutinesListScreen es un RoutineModel.
class RoutineModel {
  final String id;         // Identificador único → 'r1', 'r2' (viene del backend)
  final String day;        // Nombre del día en texto → 'LUNES', 'MONDAY' (bilingüe)
  final String title;      // Nombre de la rutina → 'Movilidad de Hombro'
  final int minutes;       // Duración estimada en minutos → 15
  final String difficulty; // Nivel de dificultad → 'BAJA' | 'MEDIA' | 'ALTA'
  final RoutineStatus status; // Estado actual de la rutina en la semana actual

  /// Constructor constante: todos los campos son obligatorios.
  /// `const` permite crear instancias en tiempo de compilación (más eficiente
  /// que `new` — útil en listas mock de RoutineService).
  const RoutineModel({
    required this.id,
    required this.day,
    required this.title,
    required this.minutes,
    required this.difficulty,
    required this.status,
  });

  /// Convierte el nombre del día (texto) al número ISO 8601 que usa Dart.
  /// Necesario para comparar con `DateTime.now().weekday` y detectar si toca hoy.
  /// Acepta español e inglés, con o sin tildes (robustez frente a variaciones del backend).
  /// Devuelve -1 si el valor de [day] no es reconocido (no coincidirá con ningún día).
  int get weekday {
    // toUpperCase() normaliza el texto → 'lunes', 'Lunes' y 'LUNES' son equivalentes
    switch (day.toUpperCase()) {
      case 'LUNES':
      case 'MONDAY':
        return DateTime.monday;    // 1
      case 'MARTES':
      case 'TUESDAY':
        return DateTime.tuesday;   // 2
      case 'MIÉRCOLES':
      case 'MIERCOLES': // Variante sin tilde por si el backend no la codifica correctamente
      case 'WEDNESDAY':
        return DateTime.wednesday; // 3
      case 'JUEVES':
      case 'THURSDAY':
        return DateTime.thursday;  // 4
      case 'VIERNES':
      case 'FRIDAY':
        return DateTime.friday;    // 5
      case 'SÁBADO':
      case 'SABADO': // Variante sin tilde
      case 'SATURDAY':
        return DateTime.saturday;  // 6
      case 'DOMINGO':
      case 'SUNDAY':
        return DateTime.sunday;    // 7
      default:
        return -1; // Valor desconocido → no coincidirá con ningún weekday real
    }
  }

  /// Constructor de fábrica: crea un RoutineModel a partir del JSON del backend.
  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] as String,
      day: json['day'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      difficulty: json['difficulty'] as String,
      // Los enums no se pueden deserializar directamente desde JSON.
      // `firstWhere` busca el valor cuyo `.name` coincida con el String del JSON.
      // Ej: 'completed' → RoutineStatus.completed
      status: RoutineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () =>
            RoutineStatus.upcoming, // Fallback seguro si el valor es desconocido
      ),
    );
  }

  /// Serializa el modelo a Map para enviarlo al backend.
  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'title': title,
        'minutes': minutes,
        'difficulty': difficulty,
        'status': status.name, // Enum → String: RoutineStatus.completed → 'completed'
      };
}
