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

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) =>
    <String, dynamic>{
      '_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'image': instance.image,
      'phoneNumber': instance.phoneNumber,
      'location': instance.location,
      'gender': instance.gender,
      'DOB': instance.dob,
      'role': instance.role,
    };
