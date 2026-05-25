import '../../../core/strings/locale_manager.dart'; // Para textos localizados de las notificaciones mock
import '../models/notification_model.dart';         // Modelo de notificación

/// Servicio de notificaciones del usuario.
/// Gestiona la obtención y marcado como leída de las notificaciones.
class NotificationService {
  /// Devuelve la lista de notificaciones del usuario autenticado.
  /// Endpoint real: GET /notifications
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400)); // Simula latencia de red
    final now = DateTime.now(); // Momento actual para calcular cuándo se creó cada notificación
    final s = LocaleManager.strings; // Alias para textos localizados

    // Devuelve cuatro notificaciones de demostración con distintos tipos y estados
    return [
      NotificationModel(
        id: 'n1',
        type: NotificationType.message,  // Mensaje directo del fisioterapeuta
        title: s.notifMsgTitle,          // "Mensaje de tu fisioterapeuta"
        body: s.notifMsgBody,            // Contenido del mensaje
        isRead: false,                   // Sin leer → aparecerá resaltada en la lista
        createdAt: now.subtract(const Duration(hours: 2)), // Hace 2 horas
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.questionnaire, // Cuestionario pendiente de rellenar
        title: s.notifQuestionnaireTitle,     // "Cuestionario de seguimiento"
        body: s.notifQuestionnaireBody,
        isRead: false,              // Sin leer
        hasAction: true,            // true → muestra botón de acción
        actionLabel: s.notifActionOpen, // "Abrir" — etiqueta del botón
        createdAt: now.subtract(const Duration(hours: 5)), // Hace 5 horas
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.reminder, // Recordatorio de sesión próxima
        title: s.notifReminderTitle,     // "Recordatorio"
        body: s.notifReminderBody,
        isRead: true,               // Ya leída → apariencia más tenue en la lista
        createdAt: now.subtract(const Duration(hours: 6)), // Hace 6 horas
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.sessionComplete, // Confirmación de sesión completada
        title: s.notifSessionCompleteTitle,     // "Sesión completada"
        body: s.notifSessionCompleteBody,
        isRead: true,               // Ya leída
        createdAt: now.subtract(const Duration(hours: 8)), // Hace 8 horas
      ),
    ];

    // TODO: Reemplazar con:
    // final response = await apiClient.get('/notifications');
    // return (response as List).map((j) => NotificationModel.fromJson(j)).toList();
  }

  /// Marca una notificación como leída en el backend.
  /// Endpoint real: PATCH /notifications/{id}
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Latencia simulada
    // TODO: Reemplazar con:
    // await apiClient.patch('/notifications/$id', {'is_read': true});
  }
}
