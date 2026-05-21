class ExerciseModel {
  final String id;
  final String name;
  final int? series;
  final int? reps;
  final int? minutes;
  final String? imageUrl;

  /// URL del vídeo demostrativo del ejercicio (futuro).
  final String? videoUrl;

  /// Ángulo de cámara del vídeo ('FRONTAL', 'LATERAL', etc.).
  final String? angle;

  /// Duración total en segundos, fijada por el fisio desde el backend.
  /// Tiene prioridad sobre el cálculo automático.
  final int? totalDurationSeconds;

  /// Ritmo de ejecución indicado por el fisio ('LENTO', 'NORMAL', 'INTENSO').
  final String? rhythm;

  /// Segundos de descanso obligatorio tras este ejercicio (null = usar default).
  final int? restAfterSeconds;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.series,
    this.reps,
    this.minutes,
    this.imageUrl,
    this.videoUrl,
    this.angle,
    this.totalDurationSeconds,
    this.rhythm,
    this.restAfterSeconds,
  });

  /// Texto descriptivo: "3 SERIES x 10 REPS" o "2 MINUTOS"
  String get subtitle {
    if (series != null && reps != null) return '$series SERIES  x  $reps REPS';
    if (minutes != null) return '$minutes MINUTOS';
    return '';
  }

  /// Duración efectiva en segundos para el temporizador:
  ///  1. Si el fisio fijó totalDurationSeconds → ese valor.
  ///  2. Si es ejercicio de mantenimiento (minutes) → minutes × 60.
  ///  3. Si es por repeticiones → series × reps × 3 s/rep (rehab controlada).
  int get effectiveDurationSeconds {
    if (totalDurationSeconds != null) return totalDurationSeconds!;
    if (minutes != null) return minutes! * 60;
    return (series ?? 1) * (reps ?? 1) * 3;
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      series: json['series'] as int?,
      reps: json['reps'] as int?,
      minutes: json['minutes'] as int?,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      angle: json['angle'] as String?,
      totalDurationSeconds: json['total_duration_seconds'] as int?,
      rhythm: json['rhythm'] as String?,
      restAfterSeconds: json['rest_after_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (series != null) 'series': series,
        if (reps != null) 'reps': reps,
        if (minutes != null) 'minutes': minutes,
        if (imageUrl != null) 'image_url': imageUrl,
        if (videoUrl != null) 'video_url': videoUrl,
        if (angle != null) 'angle': angle,
        if (totalDurationSeconds != null)
          'total_duration_seconds': totalDurationSeconds,
        if (rhythm != null) 'rhythm': rhythm,
        if (restAfterSeconds != null) 'rest_after_seconds': restAfterSeconds,
      };
}

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
