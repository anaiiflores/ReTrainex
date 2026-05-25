import '../../../features/exercises/models/exercise_detail_model.dart'; // Importa ExerciseModel

/// Re-exporta ExerciseModel para que quien importe RoutineDetailModel
/// también tenga acceso a ExerciseModel sin necesidad de un import adicional.
/// Patrón barrel: simplifica los imports en las pantallas que usan ambos modelos.
export '../../../features/exercises/models/exercise_detail_model.dart';

/// Modelo del detalle completo de una rutina.
/// Se usa en RoutineDetailScreen para mostrar la descripción y la lista de ejercicios.
/// Cada rutina tiene un ID propio y un sessionId para asociarla a una sesión concreta.
class RoutineDetailModel {
  final String id;          // Identificador de la rutina (mismo que RoutineModel.id)
  final String sessionId;   // ID de la sesión de tratamiento a la que pertenece esta rutina
  final String description; // Descripción o instrucciones de la rutina del fisioterapeuta
  final List<ExerciseModel> exercises; // Lista de ejercicios que componen la rutina

  /// Constructor constante: todos los campos son obligatorios.
  const RoutineDetailModel({
    required this.id,
    required this.sessionId,
    required this.description,
    required this.exercises,
  });

  /// Crea un RoutineDetailModel desde el JSON del backend.
  factory RoutineDetailModel.fromJson(Map<String, dynamic> json) {
    return RoutineDetailModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      description: json['description'] as String,
      // La lista de ejercicios llega como List<dynamic> en el JSON.
      // Cada elemento se convierte a ExerciseModel con fromJson.
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializa el modelo para enviarlo al backend.
  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'description': description,
        // Serializa cada ejercicio de la lista llamando a su propio toJson()
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}
