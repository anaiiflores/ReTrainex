// Los tres estados posibles de una rutina dentro de la semana del paciente
enum RoutineStatus {
  completed, // Ya realizada → muestra tick verde
  today, // Toca hoy     → resaltada en azul, botón INICIAR visible
  upcoming, // Día futuro   → bloqueada con candado
}

// Representa una rutina de un día concreto de la semana
// Cada elemento de la lista semanal es un RoutineModel
class RoutineModel {
  final String id; // Identificador único → 'r1', 'r2' (viene del backend)
  final String day; // Nombre del día en texto → 'LUNES', 'MONDAY'
  final String title; // Nombre de la rutina → 'Movilidad de Hombro'
  final int minutes; // Duración estimada en minutos → 15
  final String difficulty; // Nivel de dificultad → 'BAJA' | 'MEDIA' | 'ALTA'
  final RoutineStatus status; // Estado actual de la rutina

  // Constructor constante: todos los campos son obligatorios
  // 'const' permite crear instancias en tiempo de compilación (más eficiente)
  const RoutineModel({
    required this.id,
    required this.day,
    required this.title,
    required this.minutes,
    required this.difficulty,
    required this.status,
  });

  /// Convierte el nombre del día (texto) al número que usa Dart internamente.
  /// Necesario para comparar con DateTime.now().weekday y detectar si toca hoy.
  /// Acepta español o inglés (mayúsculas o minúsculas).
  /// Devuelve -1 si el valor de [day] no es reconocido.
  int get weekday {
    // toUpperCase() normaliza el texto antes de comparar
    // así 'lunes', 'Lunes' y 'LUNES' funcionan igual
    switch (day.toUpperCase()) {
      case 'LUNES':
      case 'MONDAY':
        return DateTime.monday; // 1
      case 'MARTES':
      case 'TUESDAY':
        return DateTime.tuesday; // 2
      case 'MIÉRCOLES':
      case 'MIERCOLES': // versión sin tilde por si el backend no la envía
      case 'WEDNESDAY':
        return DateTime.wednesday; // 3
      case 'JUEVES':
      case 'THURSDAY':
        return DateTime.thursday; // 4
      case 'VIERNES':
      case 'FRIDAY':
        return DateTime.friday; // 5
      case 'SÁBADO':
      case 'SABADO': // versión sin tilde
      case 'SATURDAY':
        return DateTime.saturday; // 6
      case 'DOMINGO':
      case 'SUNDAY':
        return DateTime.sunday; // 7
      default:
        return -1; // valor desconocido → no coincidirá con ningún día
    }
  }

  // Constructor de fábrica: crea un RoutineModel a partir de un Map JSON
  // Se usa cuando la API devuelve datos en formato JSON
  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] as String, // extrae el String del Map
      day: json['day'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      difficulty: json['difficulty'] as String,
      // El enum no se puede deserializar directamente, hay que buscarlo por nombre:
      // 'completed' → busca el valor cuyo .name sea 'completed' → RoutineStatus.completed
      status: RoutineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () =>
            RoutineStatus.upcoming, // si el valor es desconocido, usa upcoming
      ),
    );
  }

  // Convierte el objeto a un Map JSON para enviarlo a la API
  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'title': title,
        'minutes': minutes,
        'difficulty': difficulty,
        'status': status.name, // RoutineStatus.completed → 'completed'
      };
}
