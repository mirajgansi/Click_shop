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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;

          final double maxWidth = isTablet ? 480 : double.infinity;
          final double horizontalPadding = isTablet ? 0 : 16;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Image.asset(
                      'assets/images/happy.png',
                      width: isTablet ? 80 : 60,
                      height: isTablet ? 80 : 60,
                    ),

                    const SizedBox(height: 40),

                    Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: isTablet ? 30 : 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Enter your email and we’ll send you a code',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
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

                    const SizedBox(height: 24),

                    MyButtonWidgets(
                      text: authState.status == AuthStatus.loading
                          ? 'Sending...'
                          : 'Send Reset Code',
                      height: isTablet ? 56 : 50,
                      borderRadius: 14,
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
                                    builder: (_) =>
                                        ResetCodePage(initialEmail: email),
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

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
