import 'dart:io';

import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/logout_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/updateProfile_usecase.dart';
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
  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
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
      },
    );
  }
}
