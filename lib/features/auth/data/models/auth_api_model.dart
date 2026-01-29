import 'dart:math';

import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? userId;
  final String? username;
  final String email;
  final String? password;
  final String? image;
  final String? confirmPassword;

  // final String role;

  AuthApiModel({
    this.userId,
    this.username,
    required this.email,
    this.password,
    // this.profilePicture,
    this.confirmPassword,
    this.image,
  });

  //toJson
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "image": image,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      userId: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
    );
  }
  //toEnitity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      username: username,
      email: email,
      image: image,
    );
  }

  //from Enitity

  factory AuthApiModel.formEnitity(AuthEntity entity) {
    return AuthApiModel(
      username: entity.username,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      image: entity.image,
    );
  }

  // toEntityListt
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
