import '../../routines/models/routine_model.dart';

class UserModel {
  String id;
  String userName;
  RoutineModel? routine;
  DateTime? birthDate;
  double? weight;
  double? height; // en centímetros
  String? physioName;
  String? profileImageUrl;
  List<int> routineDays; // 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom

  UserModel({
    required this.id,
    required this.userName,
    this.routine,
    this.birthDate,
    this.weight,
    this.height,
    this.physioName,
    this.profileImageUrl,
    this.routineDays = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      routine: json['routine'] != null
          ? RoutineModel.fromJson(json['routine'] as Map<String, dynamic>)
          : null,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      physioName: json['physio_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      routineDays: (json['routine_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int years = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'routine': routine?.toJson(),
        'birth_date': birthDate?.toIso8601String(),
        'weight': weight,
        'height': height,
        'physio_name': physioName,
        'profile_image_url': profileImageUrl,
        'routine_days': routineDays,
      };
}
