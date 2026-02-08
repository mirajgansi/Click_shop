import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? username;
  final String email;

  final String? password;
  final String? confirmPassword;

  final String? image;
  final String? phoneNumber;
  final String? location;
  final String? gender;
  final String? dob; // Mongo: DOB
  final String? role; // user | admin | driver

  const AuthEntity({
    this.userId,
    required this.email,
    this.username,
    this.password,
    this.confirmPassword,
    this.image,
    this.phoneNumber,
    this.location,
    this.gender,
    this.dob,
    this.role,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    username,
    image,
    phoneNumber,
    location,
    gender,
    dob,
    role,
  ];
}
