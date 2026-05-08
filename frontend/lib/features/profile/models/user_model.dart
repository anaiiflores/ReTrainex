import '../../routines/models/routine_model.dart';

class UserModel {
  String _userName;
  RoutineModel? _routine;
  int? _age;
  double? _weight;

  UserModel({
    required String userName,
    RoutineModel? routine,
    int? age,
    double? weight,
  })  : _userName = userName,
        _routine = routine,
        _age = age,
        _weight = weight;

  String get userName => _userName;
  set userName(String value) => _userName = value;

  RoutineModel? get routine => _routine;
  set routine(RoutineModel? value) => _routine = value;

  int? get age => _age;
  set age(int? value) => _age = value;

  double? get weight => _weight;
  set weight(double? value) => _weight = value;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['userName'] as String,
      routine: json['routine'] != null
          ? RoutineModel.fromJson(json['routine'] as Map<String, dynamic>)
          : null,
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': _userName,
        'routine': _routine?.toJson(),
        'age': _age,
        'weight': _weight,
      };
}
