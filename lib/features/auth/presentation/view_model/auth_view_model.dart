import 'package:click_shop/features/auth/domain/usecases/login_usecase.dart';
import 'package:click_shop/features/auth/domain/usecases/register_usecase.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required String userName,
    required String email,
    required String password,
    String? profileImage,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _registerUsecase(
      RegisterUsecaseParams(
        userName: userName,
        email: email,
        password: password,
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
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.register);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        }

        //login after registration
        Future<void> login({required String email}) async {
          state = state.copyWith(status: AuthStatus.loading);
          final params = LoginUsecaseParams(
            email: email,
            password: password,
            userName: userName,
          );
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
        }
      },
    );
  }
}
