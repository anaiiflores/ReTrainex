import '../models/notification_model.dart';

class NotificationService {
  /// Endpoint real: GET /notifications
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'n1',
        type: NotificationType.message,
        title: 'Mensaje del Dr. Pérez',
        body: 'Hola María, he revisado tu progreso y se ve excelente. Sigue así con la constancia.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.questionnaire,
        title: 'Cuestionario WOMAC pendiente',
        body: 'Por favor, completa el cuestionario de evaluación semanal para que tu fisioterapeuta pueda hacer seguimiento.',
        isRead: false,
        hasAction: true,
        actionLabel: 'Abrir',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.reminder,
        title: 'Recordatorio de sesión',
        body: 'Tu sesión de hoy comienza en 30 minutos. ¡Prepárate!',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.sessionComplete,
        title: 'Sesión completada',
        body: '¡Felicitaciones! Completaste tu sesión del Lunes. Llevas 5 días de racha.',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
    // Reemplazar con:
    // final response = await apiClient.get('/notifications');
    // return (response as List).map((j) => NotificationModel.fromJson(j)).toList();
  }

  /// Endpoint real: PATCH /notifications/{id}
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // await apiClient.patch('/notifications/$id', {'is_read': true});
  }
}
