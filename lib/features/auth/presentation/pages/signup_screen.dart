import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/utils/my_snack_bar.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/core/widgets/my_button_widgets.dart';
import 'package:click_shop/core/widgets/my_text_field_widgets.dart';
import 'package:click_shop/features/auth/presentation/pages/login_screen.dart';
import 'package:click_shop/features/auth/presentation/state/auth_state.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(
        context,
        'Please agree to the Terms & Conditions',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ref
          .read(AuthViewModelProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            userName: _usernameController.text.trim().split('@').first,
          );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(AuthViewModelProvider);
    //Listen to auth state changes
    ref.listen<AuthState>(AuthViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'An error occurred',
        );
      } else if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Signup successful! Please log in.');
      }
    });

    return Scaffold(
      //auth satate
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;

          return Row(
            children: [
              if (isTablet)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Image.asset('assets/images/8140 1.jpg'),
                    ),
                  ),
                ),

              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isTablet)
                            Center(
                              child: Image.asset(
                                'assets/images/Group.jpg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),

                          const SizedBox(height: 20),

                          const Text(
                            'Signup',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Enter your credentials to continue",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),

                          const SizedBox(height: 20),

                          MyTextFieldWidgets(
                            controller: _usernameController,
                            hintText: "John Doe",
                            text: "Username",
                          ),

                          const SizedBox(height: 10),

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

                          MyTextFieldWidgets(
                            controller: _confirmPasswordController,
                            hintText: "*******",
                            text: "Confirm Password",
                            obscureText: true,
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "By continuing you agree to our Terms of Service and Privacy Policy.",
                            style: TextStyle(fontSize: 14),
                          ),

                          const SizedBox(height: 20),

                          MyButtonWidgets(
                            onPressed: () {
                              final username = _usernameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              final confirmPassword = _confirmPasswordController
                                  .text
                                  .trim();

                              if (username.isEmpty) {
                                showMySnackBar(
                                  context: context,
                                  message: "Username can't be empty",
                                  color: Colors.red,
                                );
                                return;
                              }

                              if (email.isEmpty) {
                                showMySnackBar(
                                  context: context,
                                  message: "Email can't be empty",
                                  color: Colors.red,
                                );
                                return;
                              }

                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
                                showMySnackBar(
                                  context: context,
                                  message: "Enter a valid email",
                                  color: Colors.red,
                                );
                                return;
                              }

                              if (password.isEmpty) {
                                showMySnackBar(
                                  context: context,
                                  message: "Password can't be empty",
                                  color: Colors.red,
                                );
                                return;
                              }

                              if (password.length < 8) {
                                showMySnackBar(
                                  context: context,
                                  message:
                                      "Password must be at least 8 characters",
                                  color: Colors.red,
                                );
                                return;
                              }

                              if (confirmPassword.isEmpty) {
                                showMySnackBar(
                                  context: context,
                                  message: "Confirm Password can't be empty",
                                  color: Colors.red,
                                );
                                return;
                              }

                              if (password != confirmPassword) {
                                showMySnackBar(
                                  context: context,
                                  message: "Passwords do not match",
                                  color: Colors.red,
                                );
                                return;
                              }

                              showMySnackBar(
                                context: context,
                                message: "Signup successful",
                                color: Colors.green,
                              );

                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushNamed(context, '/login');
                              });
                            },
                            text: "Sign up",
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Log in",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(context, '/login');
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
              ),
            ],
          );
        },
      ),
    );
  }
}
