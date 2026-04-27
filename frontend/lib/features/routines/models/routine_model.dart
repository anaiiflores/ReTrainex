enum RoutineStatus { completed, today, upcoming }

class RoutineModel {
  final String id;
  final String day;
  final String title;
  final int minutes;
  final String difficulty; // 'BAJA' | 'MEDIA' | 'ALTA'
  final RoutineStatus status;

  const RoutineModel({
    required this.id,
    required this.day,
    required this.title,
    required this.minutes,
    required this.difficulty,
    required this.status,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] as String,
      day: json['day'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      difficulty: json['difficulty'] as String,
      status: RoutineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoutineStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'title': title,
        'minutes': minutes,
        'difficulty': difficulty,
        'status': status.name,
      };
}
