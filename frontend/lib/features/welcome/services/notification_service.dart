import '../../../core/strings/locale_manager.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Endpoint real: GET /notifications
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final s = LocaleManager.strings;
    return [
      NotificationModel(
        id: 'n1',
        type: NotificationType.message,
        title: s.notifMsgTitle,
        body: s.notifMsgBody,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.questionnaire,
        title: s.notifQuestionnaireTitle,
        body: s.notifQuestionnaireBody,
        isRead: false,
        hasAction: true,
        actionLabel: s.notifActionOpen,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.reminder,
        title: s.notifReminderTitle,
        body: s.notifReminderBody,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.sessionComplete,
        title: s.notifSessionCompleteTitle,
        body: s.notifSessionCompleteBody,
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
