import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
  loaded,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;

  //store image temp path
  final String? UploadPhotoName;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.UploadPhotoName,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    bool clearUser = false, // ✅ add this
    String? errorMessage,
    bool clearError = false, // optional but nice
    String? UploadPhotoName,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      UploadPhotoName: UploadPhotoName ?? this.UploadPhotoName,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, UploadPhotoName];
}
