import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AuthViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(RegisterUsecaseProvider);
    _loginUsecase = ref.read(LoginUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String username,
    required String email,
    required String confirmPassword,
    required String password,
    String? profileImage,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterUsecaseParams(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        profileImage: profileImage,
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
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final params = LoginUsecaseParams(email: email, password: password);
      final result = await _loginUsecase(params);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
        },
        (authEntity) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authEntity: authEntity,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
