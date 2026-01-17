import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? profileImage;

  const AuthEntity({
    this.userId,
    required this.email,
    this.profileImage,
    this.username,
    this.password,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    email,
    profileImage,
    username,
    password,
    confirmPassword,
  ];
}
