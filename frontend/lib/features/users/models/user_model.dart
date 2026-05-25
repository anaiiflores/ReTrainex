import '../../routines/models/routine_model.dart'; // Rutina asignada al usuario por el fisioterapeuta

/// Modelo de datos del usuario autenticado.
/// Los campos son mutables (`var`/sin `final`) para permitir edición en SettingsScreen.
class UserModel {
  String id;               // Identificador único en el backend
  String userName;         // Nombre mostrado en la UI ("MARÍA")
  RoutineModel? routine;   // Rutina activa asignada por el fisio (null si aún no tiene)
  DateTime? birthDate;     // Fecha de nacimiento — usada para calcular la edad
  double? weight;          // Peso en kilogramos
  double? height;          // Altura en centímetros
  String? physioName;      // Nombre del fisioterapeuta responsable del tratamiento
  String? profileImageUrl; // URL de la foto de perfil (null → mostrar avatar genérico)

  /// Lista de días de la semana en que el usuario tiene rutina programada.
  /// Codificación: 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom
  /// (mismo convenio que WeekDaySelector e índices de DateTime.weekday - 1)
  List<int> routineDays;

  UserModel({
    required this.id,
    required this.userName,
    this.routine,
    this.birthDate,
    this.weight,
    this.height,
    this.physioName,
    this.profileImageUrl,
    this.routineDays = const [], // Por defecto, ningún día programado
  });

  /// Crea un UserModel a partir del JSON devuelto por el backend.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,                         // Campo obligatorio
      userName: json['userName'] as String,             // Campo obligatorio
      routine: json['routine'] != null
          ? RoutineModel.fromJson(json['routine'] as Map<String, dynamic>) // Deserializa la rutina anidada
          : null,                                        // null si el backend no envió rutina
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String) // ISO 8601 → DateTime ("1992-12-01")
          : null,
      weight: (json['weight'] as num?)?.toDouble(),     // num? cubre tanto int como double del JSON
      height: (json['height'] as num?)?.toDouble(),     // ?. evita NPE si el campo es null
      physioName: json['physio_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      routineDays: (json['routine_days'] as List<dynamic>?) // Puede no venir en el JSON
              ?.map((e) => e as int)  // Convierte cada elemento dynamic a int
              .toList() ??            // ?? [] → lista vacía si el campo era null
          [],
    );
  }

  /// Calcula la edad del usuario en años completos.
  /// Devuelve null si no se conoce la fecha de nacimiento.
  int? get age {
    if (birthDate == null) return null; // Sin fecha → edad desconocida
    final today = DateTime.now();
    int years = today.year - birthDate!.year; // Diferencia de años calendario
    // Si aún no ha llegado el cumpleaños de este año → restar 1
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      years--; // El cumpleaños todavía no ha ocurrido en el año actual
    }
    return years;
  }

  /// Serializa el modelo a Map para enviarlo al backend (ej. PUT /me).
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'routine': routine?.toJson(),                    // ?.toJson() → null si no hay rutina
        'birth_date': birthDate?.toIso8601String(),      // "1992-12-01T00:00:00.000" o null
        'weight': weight,
        'height': height,
        'physio_name': physioName,
        'profile_image_url': profileImageUrl,
        'routine_days': routineDays,                     // Lista de ints directamente serializable
      };
}
