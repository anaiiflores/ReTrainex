import '../../../features/exercises/models/exercise_detail_model.dart';

export '../../../features/exercises/models/exercise_detail_model.dart';

class RoutineDetailModel {
  final String id;
  final String sessionId;
  final String description;
  final List<ExerciseModel> exercises;

  const RoutineDetailModel({
    required this.id,
    required this.sessionId,
    required this.description,
    required this.exercises,
  });

  factory RoutineDetailModel.fromJson(Map<String, dynamic> json) {
    return RoutineDetailModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      description: json['description'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
