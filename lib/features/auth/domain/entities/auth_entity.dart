import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? image;

  const AuthEntity({
    this.userId,
    required this.email,
    this.image,
    this.username,
    this.password,
    this.confirmPassword,
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
