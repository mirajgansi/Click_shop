import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/app/theme/app_colors.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';
import 'package:click_shop/features/auth/presentation/pages/signup_page.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_navigation_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    print("Trying login with email: ${_emailController.text}");
    if (_formKey.currentState!.validate()) {
      await ref
          .read(AuthViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            onNavigate: (route) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (context) => false,
              );
            },
          );
    }
  }

  void _navigateToSignup() {
    AppRoutes.push(context, const SignupScreen());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = cs.onSurface.withOpacity(0.7);

    final authState = ref.watch(AuthViewModelProvider);

    ref.listen<AuthState>(AuthViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Login successful');
        AppRoutes.pushReplacement(context, DashboardScreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: cs.surfaceContainerHighest,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;

          return Row(
            children: [
              if (isTablet)
                Expanded(
                  child: Container(
                    color: cs.surface,
                    child: Center(
                      child: Image.asset(
                        'assets/images/8140 1.jpg',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isTablet)
                          Center(
                            child: Image.asset(
                              'assets/images/happy.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 20),

                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          "Enter your Email and Password",
                          style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        const SizedBox(height: 20),

                        MyTextFieldWidgets(
                          controller: _emailController,
                          hintText: "example600@gmail.com",
                          text: "Email",
                        ),

                        const SizedBox(height: 10),

                        MyTextFieldWidgets(
                          controller: _passwordController,
                          hintText: "*******",
                          text: "Password",
                          obscureText: true,
                        ),

                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/forgotpassword'),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.primary,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        MyButtonWidgets(
                          onPressed: _handleLogin,
                          isLoading: authState.status == AuthStatus.loading,
                          text: "Log in",
                          height: 50,
                          borderRadius: 16,
                        ),

                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: cs.outlineVariant.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 16,
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),

                              children: [
                                TextSpan(
                                  text: "Sign up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      AppRoutes.pushReplacement(
                                        context,
                                        SignupScreen(),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
