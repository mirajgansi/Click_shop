import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? image;
  final String? location;
  final String? phoneNumber;

  const AuthEntity({
    this.userId,
    required this.email,
    this.image,
    this.username,
    this.password,
    this.confirmPassword,
    this.location,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    email,
    image,
    username,
    password,
    confirmPassword,
  ];
}
