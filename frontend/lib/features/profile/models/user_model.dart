import '../../routines/models/routine_model.dart';

class UserModel {
  String _userName;
  RoutineModel? _routine;

  UserModel({
    required String userName,
    RoutineModel? routine,
  })  : _userName = userName,
        _routine = routine;

  String get userName => _userName;
  set userName(String value) => _userName = value;

  RoutineModel? get routine => _routine;
  set routine(RoutineModel? value) => _routine = value;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['userName'] as String,
      routine: json['routine'] != null
          ? RoutineModel.fromJson(json['routine'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': _userName,
        'routine': _routine?.toJson(),
      };
}
