import 'package:click_shop/features/auth/presentation/pages/frogotpassword_page.dart';
import 'package:click_shop/features/auth/presentation/pages/reset_code_page.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A test AuthViewModel that lets us control state + capture calls.
class TestAuthViewModel extends AuthViewModel {
  TestAuthViewModel(this._initial) : super();
  AuthState _initial;

  String? lastRequestedEmail;

  @override
  AuthState build() => _initial;

  @override
  Future<void> requestPasswordReset(String email) async {
    lastRequestedEmail = email;

    // simulate loading -> loaded
    state = state.copyWith(status: AuthStatus.loading);
    await Future<void>.delayed(Duration.zero);
    state = state.copyWith(status: AuthStatus.loaded);
  }
}

void main() {
  Widget wrapWithApp(Widget child, {required TestAuthViewModel vm}) {
    return ProviderScope(
      overrides: [
        // Override ONLY this provider; the screen reads both state and notifier.
        AuthViewModelProvider.overrideWith(() => vm),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('renders Forgot Password UI', (tester) async {
    final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));

    await tester.pumpWidget(wrapWithApp(const ForgotPasswordScreen(), vm: vm));

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Send Reset Code'), findsOneWidget);
    expect(
      find.text('Enter your email and we’ll send you a code'),
      findsOneWidget,
    );
  });

  testWidgets('invalid email -> shows error snackbar text', (tester) async {
    final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));

    await tester.pumpWidget(wrapWithApp(const ForgotPasswordScreen(), vm: vm));

    // Tap button without entering valid email
    await tester.tap(find.text('Send Reset Code'));
    await tester.pump(); // show snackbar

    // SnackbarUtils.showError shows a SnackBar with this message
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(vm.lastRequestedEmail, isNull); // should not call usecase
  });

  testWidgets(
    'valid email -> calls requestPasswordReset and navigates to ResetCodePage',
    (tester) async {
      final vm = TestAuthViewModel(AuthState(status: AuthStatus.initial));

      await tester.pumpWidget(
        wrapWithApp(const ForgotPasswordScreen(), vm: vm),
      );

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');

      await tester.tap(find.text('Send Reset Code'));

      await tester.pump();

      await tester.pumpAndSettle();

      expect(vm.lastRequestedEmail, 'a@b.com');
      expect(find.byType(ResetCodePage), findsOneWidget);
      expect(find.text('Reset code sent to your email'), findsOneWidget);
    },
  );
}
