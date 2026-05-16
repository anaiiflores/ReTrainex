import '../../routines/models/routine_model.dart';
import '../models/user_model.dart';

class UserService {
  static final UserModel _mockUser = UserModel(
    id: 'u1',
    userName: 'María',
    age: 34, // en años
    weight: 62.5, // en kilos
    routine: RoutineModel(
      id: 'r2',
      day: 'MIÉRCOLES',
      title: 'Fortalecimiento Escapular',
      minutes: 20,
      difficulty: 'MEDIA',
      status: RoutineStatus.today,
    ),
  );

  Future<UserModel> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser;
    // TODO: Reemplazar con:
    // final response = await apiClient.get('/me');
    // return UserModel.fromJson(response);
  }
}
