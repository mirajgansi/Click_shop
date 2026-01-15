import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String username;
  final String email;
  final String? password;
  final String? profileImage;

  const AuthEntity({
    this.userId,
    required this.email,
    this.profileImage,
    required this.username,
    this.password,
  });

  @override
  List<Object?> get props => [email, profileImage, username, password];
}
