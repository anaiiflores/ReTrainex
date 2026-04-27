enum RoutineStatus { none, newAssignment, active }

class NextSessionModel {
  final String date;          // "15 OCT"
  final String time;          // "10:30 AM"
  final int durationMinutes;  // 15
  final String type;          // "FISIOTERAPIA"

  const NextSessionModel({
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.type,
  });

  factory NextSessionModel.fromJson(Map<String, dynamic> json) {
    return NextSessionModel(
      date: json['date'] as String,
      time: json['time'] as String,
      durationMinutes: json['duration_minutes'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'duration_minutes': durationMinutes,
        'type': type,
      };
}

class DashboardModel {
  final String userName;
  final RoutineStatus status;
  final int progressPercentage;  // 0–100
  final int completedSessions;
  final int totalSessions;
  final bool hasUnreadNotification;
  final NextSessionModel? nextSession;
  final String? reminder;
  // Solo cuando status == newAssignment
  final String? assignmentTitle;
  final String? physioName;

  const DashboardModel({
    required this.userName,
    required this.status,
    this.progressPercentage = 0,
    this.completedSessions = 0,
    this.totalSessions = 0,
    this.hasUnreadNotification = false,
    this.nextSession,
    this.reminder,
    this.assignmentTitle,
    this.physioName,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String;
    final status = RoutineStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => RoutineStatus.none,
    );
    return DashboardModel(
      userName: json['user_name'] as String,
      status: status,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      hasUnreadNotification: json['has_unread_notification'] as bool? ?? false,
      nextSession: json['next_session'] != null
          ? NextSessionModel.fromJson(
              json['next_session'] as Map<String, dynamic>)
          : null,
      reminder: json['reminder'] as String?,
      assignmentTitle: json['assignment_title'] as String?,
      physioName: json['physio_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_name': userName,
        'status': status.name,
        'progress_percentage': progressPercentage,
        'completed_sessions': completedSessions,
        'total_sessions': totalSessions,
        'has_unread_notification': hasUnreadNotification,
        if (nextSession != null) 'next_session': nextSession!.toJson(),
        if (reminder != null) 'reminder': reminder,
        if (assignmentTitle != null) 'assignment_title': assignmentTitle,
        if (physioName != null) 'physio_name': physioName,
      };
}
