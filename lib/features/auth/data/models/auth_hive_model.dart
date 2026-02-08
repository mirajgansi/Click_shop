import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authtypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String? username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? confirmPassword;

  @HiveField(5)
  final String? image;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final String? location;

  @HiveField(8)
  final String? gender;

  @HiveField(9)
  final String? dob; // Mongo: DOB (string)

  @HiveField(10)
  final String? role; // "user" | "admin" | "driver"

  AuthHiveModel({
    String? userId,
    required this.email,
    required this.username,
    this.password,
    this.confirmPassword,
    this.image,
    this.phoneNumber,
    this.location,
    this.gender,
    this.dob,
    this.role,
  }) : userId = userId ?? const Uuid().v4();

  AuthHiveModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
    String? image,
    String? phoneNumber,
    String? location,
    String? gender,
    String? dob,
    String? role,
  }) {
    return AuthHiveModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      image: image ?? this.image,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      role: role ?? this.role,
    );
  }

  //from entity to hive model
  factory AuthHiveModel.fromEntity(AuthEntity authEntity) {
    return AuthHiveModel(
      userId: authEntity.userId,
      email: authEntity.email,
      username: authEntity.username,
      password: authEntity.password,
      confirmPassword: authEntity.confirmPassword,
      image: authEntity.image,
      phoneNumber: authEntity.phoneNumber,
      location: authEntity.location,
      gender: authEntity.gender,
      dob: authEntity.dob,
      role: authEntity.role,
    );
  }

  //to entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      image: image,
      phoneNumber: phoneNumber,
      location: location,
      gender: gender,
      dob: dob,
      role: role,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> hiveModels) {
    return hiveModels.map((model) => model.toEntity()).toList();
  }
}
