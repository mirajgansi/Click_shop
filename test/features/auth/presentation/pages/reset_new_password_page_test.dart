import 'package:click_shop/features/auth/presentation/pages/reset_new_password_page.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestAuthViewModel extends AuthViewModel {
  TestAuthViewModel(this._initial) : super();
  AuthState _initial;

  // controls behavior
  bool resetShouldSucceed = true;

  // capture inputs
  String? lastEmail;
  String? lastCode;
  String? lastNewPassword;

  @override
  AuthState build() => _initial;

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    lastEmail = email;
    lastCode = code;
    lastNewPassword = newPassword;

    state = state.copyWith(status: AuthStatus.loading);
    await Future<void>.delayed(Duration.zero);

    if (resetShouldSucceed) {
      state = state.copyWith(status: AuthStatus.loaded, errorMessage: null);
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: state.errorMessage ?? 'Reset failed',
      );
    }
  }
}

Widget wrapWithApp(Widget child, TestAuthViewModel vm) {
  return ProviderScope(
    overrides: [AuthViewModelProvider.overrideWith(() => vm)],
    child: MaterialApp(
      routes: {
        '/login': (_) =>
            const Scaffold(body: Center(child: Text('LOGIN_PAGE'))),
      },
      home: child,
    ),
  );
}

void main() {
  testWidgets('renders ResetNewPasswordPage UI', (tester) async {
    final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));

    await tester.pumpWidget(
      wrapWithApp(
        const ResetNewPasswordPage(email: 'a@b.com', code: '123456'),
        vm,
      ),
    );

    expect(find.text('Set new password'), findsOneWidget);
    expect(find.textContaining('a@b.com'), findsOneWidget);
    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('shows validation error when password < 8 chars', (tester) async {
    final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));

    await tester.pumpWidget(
      wrapWithApp(
        const ResetNewPasswordPage(email: 'a@b.com', code: '123456'),
        vm,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '123');
    await tester.enterText(find.byType(TextFormField).at(1), '123');

    await tester.tap(find.text('Reset password'));
    await tester.pump();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('shows validation error when passwords do not match', (
    tester,
  ) async {
    final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));

    await tester.pumpWidget(
      wrapWithApp(
        const ResetNewPasswordPage(email: 'a@b.com', code: '123456'),
        vm,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password999');

    await tester.tap(find.text('Reset password'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('success -> shows success snackbar and navigates to /login', (
    tester,
  ) async {
    final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));
    vm.resetShouldSucceed = true;

    await tester.pumpWidget(
      wrapWithApp(
        const ResetNewPasswordPage(email: 'a@b.com', code: '123456'),
        vm,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Reset password'));

    await tester.pump();
    await tester.pumpAndSettle();

    expect(vm.lastEmail, 'a@b.com');
    expect(vm.lastCode, '123456');
    expect(vm.lastNewPassword, 'password123');

    expect(find.text('LOGIN_PAGE'), findsOneWidget);

    expect(find.text('Password reset successfully'), findsOneWidget);
  });
}
