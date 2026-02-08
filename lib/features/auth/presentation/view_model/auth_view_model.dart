import 'dart:io';

import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/usecases/delete_me_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/logout_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/requeset_password_reset_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/reset_password.dart';
import 'package:click_shop/features/auth/domain/usecases/updateProfile_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AuthViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final UpdateUserUsecase _updateUserUsecase;
  late final DeleteMeUsecase _deleteMeUsecase;
  late final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;
  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _updateUserUsecase = ref.read(updateUserUsecaseProvider);
    _deleteMeUsecase = ref.read(deleteMeUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(
      requestPasswordResetUsecaseProvider,
    );
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String username,
    required String email,
    required String confirmPassword,
    required String password,
    // String? profileImage,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterUsecaseParams(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        // profileImage: profileImage,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) async {
        if (!isRegistered) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        } else {
          state = state.copyWith(status: AuthStatus.registered);
        }
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  //update user
  Future<void> updateProfile(File image) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _updateProfileUsecase(
      UpdateProfileUsecaseParams(image: image.path),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (imagePath) {
        state = state.copyWith(
          status: AuthStatus.loaded,
          UploadPhotoName: imagePath,
        );

        // Optional: also update user entity in state if you want
        final current = state.user;
        if (current != null) {
          state = state.copyWith(
            user: AuthEntity(
              userId: current.userId,
              email: current.email,
              username: current.username,
              password: current.password,
              confirmPassword: current.confirmPassword,
              image: imagePath,
              phoneNumber: current.phoneNumber,
              location: current.location,
              gender: current.gender,
              dob: current.dob,
              role: current.role,
            ),
          );
        }
      },
    );
  }

  // ✅ NEW: update user fields
  Future<void> updateUser(AuthEntity user) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _updateUserUsecase(UpdateUserParams(user: user));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (updatedUser) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      ),
    );
  }

  // ✅ NEW: request password reset
  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _requestPasswordResetUsecase(
      RequestPasswordResetParams(email: email),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.loaded),
    );
  }

  // ✅ NEW: reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(token: token, newPassword: newPassword),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.loaded),
    );
  }

  Future<void> deleteMeWithPassword(String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _deleteMeUsecase(DeleteMeParams(password: password));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }
}
