// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
      userId: json['_id'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
      image: json['image'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      location: json['location'] as String?,
      gender: json['gender'] as String?,
      dob: json['DOB'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.userId);
  writeNotNull('username', instance.username);
  val['email'] = instance.email;
  writeNotNull('password', instance.password);
  writeNotNull('confirmPassword', instance.confirmPassword);
  writeNotNull('image', instance.image);
  writeNotNull('phoneNumber', instance.phoneNumber);
  writeNotNull('location', instance.location);
  writeNotNull('gender', instance.gender);
  writeNotNull('DOB', instance.dob);
  writeNotNull('role', instance.role);
  return val;
}
