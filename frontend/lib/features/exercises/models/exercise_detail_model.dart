/// Modelo de datos de un ejercicio individual.
/// Contiene tanto los campos básicos (nombre, series, reps)
/// como metadatos opcionales que el fisioterapeuta puede configurar desde el backend
/// (vídeo, ángulo de cámara, duración total, ritmo, descanso).
class ExerciseModel {
  final String id;    // Identificador único del ejercicio en el backend
  final String name;  // Nombre legible del ejercicio ("Rotación de hombros")

  // ── Carga de trabajo ────────────────────────────────────────────────────
  final int? series;  // Número de series (null si es ejercicio de mantenimiento por tiempo)
  final int? reps;    // Repeticiones por serie (null si es por tiempo)
  final int? minutes; // Duración en minutos para ejercicios de mantenimiento (null si es por reps)

  // ── Multimedia ───────────────────────────────────────────────────────────
  final String? imageUrl; // URL de la imagen de portada del ejercicio (thumbnail)

  /// URL del vídeo demostrativo del ejercicio (futuro — pendiente de implementar).
  final String? videoUrl;

  /// Ángulo de cámara del vídeo ('FRONTAL', 'LATERAL', etc.) informado por el fisio.
  final String? angle;

  // ── Configuración del fisio ───────────────────────────────────────────────
  /// Duración total en segundos fijada explícitamente por el fisio desde el backend.
  /// Tiene prioridad sobre el cálculo automático de effectiveDurationSeconds.
  final int? totalDurationSeconds;

  /// Ritmo de ejecución indicado por el fisio ('LENTO', 'NORMAL', 'INTENSO').
  /// Se muestra como tag y en SessionPausedScreen.
  final String? rhythm;

  /// Segundos de descanso obligatorio tras este ejercicio.
  /// null → WorkoutRestScreen usa su valor por defecto (15 segundos).
  final int? restAfterSeconds;

  /// Constructor constante: permite crear instancias de ExerciseModel en tiempo
  /// de compilación (ej. en ExerciseService.mockExercises), más eficiente.
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

  /// Duración efectiva en segundos para el temporizador de WorkoutExerciseScreen.
  /// Jerarquía de prioridad:
  ///  1. Si el fisio fijó totalDurationSeconds → ese valor exacto.
  ///  2. Si es ejercicio de mantenimiento (minutes) → minutos × 60.
  ///  3. Si es por repeticiones → series × reps × 3 segundos/rep (ritmo controlado de rehab).
  /// Si no hay ningún dato → devuelve (1×1×3) = 3 segundos (fallback de seguridad).
  int get effectiveDurationSeconds {
    if (totalDurationSeconds != null) return totalDurationSeconds!;
    if (minutes != null) return minutes! * 60; // Convierte minutos a segundos
    return (series ?? 1) * (reps ?? 1) * 3;   // ?? 1 evita multiplicar por null
  }

  /// Crea un ExerciseModel a partir del JSON del backend.
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      series: json['series'] as int?,                             // int? → null si el campo no existe
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

  /// Serializa el modelo a Map para enviarlo al backend.
  /// Solo incluye los campos que tienen valor (if en collection literal).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (series != null) 'series': series,                                     // Solo si no es null
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
