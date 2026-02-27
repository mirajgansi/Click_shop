import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';
import 'package:click_shop/features/auth/presentation/pages/login_page.dart';
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

  final bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;
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
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return;
    }
    if (!_agreedToTerms) {
      SnackbarUtils.showError(
        context,
        'Please agree to the Terms & Conditions',
      );
      return;
    }
    ref
        .read(AuthViewModelProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
          username: _usernameController.text.trim().split('@').first,
        );
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final authState = ref.watch(AuthViewModelProvider);
    //Listen to auth state changes
    ref.listen<AuthState>(AuthViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration failed',
        );
      }

      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, 'Signup successful!');
        AppRoutes.pushReplacement(context, LoginPage());
      }
    });

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,

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
                    color: cs.surfaceContainerHighest,
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
                                'assets/images/happy.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),

                          const SizedBox(height: 20),
                          Text(
                            'Signup',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),

                          const SizedBox(height: 10),
                          Text(
                            "Enter your credentials to continue",
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 20),

                          MyTextFieldWidgets(
                            controller: _usernameController,
                            hintText: "John Doe",
                            text: "Username",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Username is required";
                              }
                              if (value.length < 3) {
                                return "Username must be at least 3 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          MyTextFieldWidgets(
                            controller: _emailController,
                            hintText: "example600@gmail.com",
                            text: "Email",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          MyTextFieldWidgets(
                            controller: _passwordController,
                            hintText: "*******",
                            text: "Password",
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          MyTextFieldWidgets(
                            controller: _confirmPasswordController,
                            hintText: "*******",
                            text: "Confirm Password",
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                activeColor: cs.primary,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: cs.outlineVariant.withOpacity(0.8),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  "I agree to the Terms of Service and Privacy Policy",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: cs.onSurface.withOpacity(0.75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          MyButtonWidgets(
                            onPressed: _handleSignup,
                            isLoading: authState.status == AuthStatus.loading,
                            text: "Sign up",
                            height: 50,
                            borderRadius: 16,
                          ),

                          const SizedBox(height: 20),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Log in",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: cs.primary,
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
