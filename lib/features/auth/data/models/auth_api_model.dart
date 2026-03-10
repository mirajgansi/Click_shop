import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_api_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AuthApiModel {
  @JsonKey(name: '_id')
  final String? userId;

  final String? username;
  final String email;

  final String? password;
  final String? confirmPassword;

  final String? image;
  final String? phoneNumber;
  final String? location;
  final String? gender;

  @JsonKey(name: 'DOB')
  final String? dob;

  final String? role;

  AuthApiModel({
    this.userId,
    this.username,
    required this.email,
    this.password,
    this.confirmPassword,
    this.image,
    this.phoneNumber,
    this.location,
    this.gender,
    this.dob,
    this.role,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      username: username,
      email: email,
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

  factory AuthApiModel.formEnitity(AuthEntity entity) {
    return AuthApiModel(
      userId: entity.userId,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      image: entity.image,
      phoneNumber: entity.phoneNumber,
      location: entity.location,
      gender: entity.gender,
      dob: entity.dob,
      role: entity.role,
    );
  }

  AuthHiveModel toHiveModel() {
    return AuthHiveModel(
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

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  Map<String, dynamic> toProfileUpdateJson() {
    final json = toJson();

    json.remove('password');
    json.remove('confirmPassword');
    json.remove('_id');
    json.remove('role');
    json.removeWhere((k, v) => v == null);

    return json;
  }
}
