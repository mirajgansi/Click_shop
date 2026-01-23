import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? imageUrl;

  const AuthEntity({
    this.userId,
    required this.email,
    this.imageUrl,
    this.username,
    this.password,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    email,
    imageUrl,
    username,
    password,
    confirmPassword,
  ];
}
