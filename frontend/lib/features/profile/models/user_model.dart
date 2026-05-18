import '../../routines/models/routine_model.dart';

class UserModel {
  String _id;
  String _userName;
  RoutineModel? _routine;
  int? _age;
  double? _weight;
  List<int> _routineDays; // 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom

  UserModel({
    required String id,
    required String userName,
    RoutineModel? routine,
    int? age,
    double? weight,
    List<int> routineDays = const [],
  })  : _id = id,
        _userName = userName,
        _routine = routine,
        _age = age,
        _weight = weight,
        _routineDays = routineDays;

  String get id => _id;
  set id(String value) => _id = value;

  String get userName => _userName;
  set userName(String value) => _userName = value;

  RoutineModel? get routine => _routine;
  set routine(RoutineModel? value) => _routine = value;

  int? get age => _age;
  set age(int? value) => _age = value;

  double? get weight => _weight;
  set weight(double? value) => _weight = value;

  List<int> get routineDays => _routineDays;
  set routineDays(List<int> value) => _routineDays = value;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      routine: json['routine'] != null
          ? RoutineModel.fromJson(json['routine'] as Map<String, dynamic>)
          : null,
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      routineDays: (json['routine_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'userName': _userName,
        'routine': _routine?.toJson(),
        'age': _age,
        'weight': _weight,
        'routine_days': _routineDays,
      };
}
