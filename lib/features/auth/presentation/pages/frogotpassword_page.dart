import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
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
              'Enter your email and we’ll send you a reset link',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            MyTextFieldWidgets(
              controller: emailController,
              hintText: 'Enter your email',
              text: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email cannot be empty';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            MyButtonWidgets(
              text: authState.status == AuthStatus.loading
                  ? 'Sending...'
                  : 'Send Reset Link',
              height: 50,
              borderRadius: 12,
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () async {
                      await authViewModel.requestPasswordReset(
                        emailController.text.trim(),
                      );

                      if (context.mounted &&
                          ref.read(AuthViewModelProvider).status ==
                              AuthStatus.loaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset link sent to your email',
                            ),
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
