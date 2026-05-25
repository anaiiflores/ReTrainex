import '../../../core/strings/locale_manager.dart'; // Para los textos "Hace X minutos"

/// Tipos de notificación que puede recibir el usuario.
/// Controla el icono y el color de la tarjeta en NotificationsScreen.
enum NotificationType {
  message,           // Mensaje directo del fisioterapeuta
  questionnaire,     // Cuestionario de seguimiento pendiente de rellenar
  reminder,          // Recordatorio de sesión próxima
  sessionComplete,   // Confirmación de sesión completada correctamente
}

/// Modelo de una notificación individual.
/// Se usa en NotificationsScreen para construir la lista de avisos.
class NotificationModel {
  final String id;                 // Identificador único en el backend
  final NotificationType type;     // Tipo de notificación (controla icono/color)
  final String title;              // Título corto de la notificación
  final String body;               // Cuerpo del mensaje (texto completo)
  final DateTime createdAt;        // Momento exacto en que se creó la notificación
  final bool isRead;               // true → ya leída (icono sin badge); false → no leída
  final bool hasAction;            // true → tiene botón de acción (ej. "Completar cuestionario")
  final String? actionLabel;       // Texto del botón de acción (null si hasAction == false)

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,       // Por defecto, las notificaciones llegan sin leer
    this.hasAction = false,    // Por defecto, sin botón de acción
    this.actionLabel,
  });

  /// Texto relativo al tiempo transcurrido desde la creación ("Hace 5 minutos").
  /// Usa los métodos de string localizados para soporte multilingüe.
  String get timeAgoText {
    final s = LocaleManager.strings;
    final diff = DateTime.now().difference(createdAt); // Duración entre ahora y createdAt
    if (diff.inMinutes < 60) return s.timeAgoMinutes(diff.inMinutes); // "Hace X min"
    if (diff.inHours < 24) return s.timeAgoHours(diff.inHours);       // "Hace X horas"
    return s.timeAgoDays(diff.inDays);                                 // "Hace X días"
  }

  /// Crea un NotificationModel desde el JSON del backend.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String; // Lee el tipo como String
    // Mapea el String al valor correspondiente del enum
    final type = NotificationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NotificationType.message, // Fallback seguro si el tipo es desconocido
    );
    return NotificationModel(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String), // ISO 8601 → DateTime
      isRead: json['is_read'] as bool? ?? false,               // ?? false → no leída por defecto
      hasAction: json['has_action'] as bool? ?? false,
      actionLabel: json['action_label'] as String?,
    );
  }

  /// Serializa el modelo para enviarlo al backend (ej. al marcar como leída).
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,                          // Enum → String ("message", "reminder", etc.)
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(), // DateTime → "2026-05-26T10:30:00.000"
        'is_read': isRead,
        'has_action': hasAction,
        if (actionLabel != null) 'action_label': actionLabel, // Solo si hay etiqueta de acción
      };
}
