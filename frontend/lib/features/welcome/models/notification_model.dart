enum NotificationType { message, questionnaire, reminder, sessionComplete }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final bool hasAction;
  final String? actionLabel;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.hasAction = false,
    this.actionLabel,
  });

  /// "Hace X minutos / horas / días"
  String get timeAgoText {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} minutos';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    return 'Hace ${diff.inDays} días';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = NotificationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NotificationType.message,
    );
    return NotificationModel(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      hasAction: json['has_action'] as bool? ?? false,
      actionLabel: json['action_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'has_action': hasAction,
        if (actionLabel != null) 'action_label': actionLabel,
      };
}
