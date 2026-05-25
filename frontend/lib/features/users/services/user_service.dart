import '../../routines/models/routine_model.dart'; // Para construir la rutina del mock
import '../models/user_model.dart';                // Modelo que este servicio gestiona

/// Servicio de acceso a datos del usuario autenticado.
/// Actualmente devuelve un usuario estático (mock); se conectará al endpoint /me del backend.
class UserService {
  /// Usuario de demostración con datos representativos para desarrollo.
  /// `static` → instancia única compartida entre todos los UserService (no se recrea).
  /// `final` → la referencia al objeto no cambia, pero sus campos sí son mutables.
  static final UserModel _mockUser = UserModel(
    id: 'u1',                              // ID fijo del usuario mock
    userName: 'María',                    // Nombre mostrado en pantallas de bienvenida
    birthDate: DateTime(1992, 12, 1),     // 1 de diciembre de 1992 → 33 años en 2026
    weight: 62.5,                         // Peso en kilogramos
    height: 164.0,                        // Altura en centímetros
    physioName: 'Anaii Penev Gordo',      // Fisioterapeuta asignada
    profileImageUrl: null,                // Sin foto de perfil → se muestra avatar genérico
    routineDays: [0, 2, 4],              // Lunes (0), Miércoles (2), Viernes (4)
    routine: RoutineModel(
      id: 'r2',
      day: 'MIÉRCOLES',                  // Día de la semana de la rutina activa
      title: 'Fortalecimiento Escapular', // Título mostrado en la tarjeta de rutina
      minutes: 20,                        // Duración estimada de la sesión
      difficulty: 'MEDIA',               // Nivel de esfuerzo
      status: RoutineStatus.today,       // Estado: es la rutina de hoy
    ),
  );

  /// Devuelve el perfil del usuario autenticado.
  /// `async` habilita `await`; retorna `Future<UserModel>` automáticamente.
  Future<UserModel> getUser() async {
    // Simula la latencia de red (300 ms) sin bloquear el hilo de la UI.
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser; // Devuelve el usuario estático mientras no hay backend real

    // TODO: Reemplazar con:
    // final response = await apiClient.get('/me');
    // return UserModel.fromJson(response);
  }
}
