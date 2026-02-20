import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/presentation/pages/reset_code_page.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(AuthViewModelProvider);
    final authViewModel = ref.read(AuthViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/Group.jpg', width: 60, height: 60),
            const SizedBox(height: 40),
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your email and we’ll send you a code',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            MyTextFieldWidgets(
              controller: emailController,
              hintText: 'Enter your email',
              text: 'Email',
              validator: (value) {
                final v = value?.trim() ?? "";
                if (v.isEmpty) return 'Email cannot be empty';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),

            const SizedBox(height: 20),

            MyButtonWidgets(
              text: authState.status == AuthStatus.loading
                  ? 'Sending...'
                  : 'Send Reset Code',
              height: 50,
              borderRadius: 12,
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        SnackbarUtils.showError(
                          context,
                          "Please enter a valid email",
                        );
                        return;
                      }

                      await authViewModel.requestPasswordReset(email);

                      final st = ref.read(AuthViewModelProvider);
                      if (!context.mounted) return;

                      if (st.status == AuthStatus.loaded) {
                        SnackbarUtils.showSuccess(
                          context,
                          "Reset code sent to your email",
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResetCodePage(initialEmail: email),
                          ),
                        );
                      }
                    },
            ),

            if (authState.status == AuthStatus.error)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  authState.errorMessage ?? 'Something went wrong',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
