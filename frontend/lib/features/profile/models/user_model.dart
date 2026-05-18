import '../../routines/models/routine_model.dart';

class UserModel {
  String id;
  String userName;
  RoutineModel? routine;
  int? age;
  double? weight;
  List<int> routineDays; // 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom

  UserModel({
    required this.id,
    required this.userName,
    this.routine,
    this.age,
    this.weight,
    this.routineDays = const [],
  });

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
        'id': id,
        'userName': userName,
        'routine': routine?.toJson(),
        'age': age,
        'weight': weight,
        'routine_days': routineDays,
      };
}
