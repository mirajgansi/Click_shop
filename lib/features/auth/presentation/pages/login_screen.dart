import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/utils/my_snack_bar.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/core/widgets/my_button_widgets.dart';
import 'package:click_shop/core/widgets/my_text_field_widgets.dart';
import 'package:click_shop/features/auth/presentation/pages/signup_screen.dart';
import 'package:click_shop/screens/bottom_screen/home_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _obscurePassword = true;
    bool _isLoading = false;

    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

    Future<void> _handleLogin() async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        // TODO: Implement login logic
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Navigate to dashboard
          AppRoutes.pushReplacement(context, const HomeScreen());
        }
      }
    }

    void _navigateToSignup() {
      AppRoutes.push(context, const SignupScreen());
    }

    void _handleForgotPassword() {
      // TODO: Implement forgot password
      SnackbarUtils.showInfo(context, 'Forgot password feature coming soon');
    }

    void _handleGoogleSignIn() {
      // TODO: Implement Google Sign In
      SnackbarUtils.showInfo(context, 'Google Sign In coming soon');
    }

    void _handleAppleSignIn() {
      // TODO: Implement Apple Sign In
      SnackbarUtils.showInfo(context, 'Apple Sign In coming soon');
    }

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;

          return Row(
            children: [
              if (isTablet)
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,
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
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Enter your Email and Password",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
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
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      MyButtonWidgets(
                        onPressed: () {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

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
                              message: "Password must be at least 8 characters",
                              color: Colors.red,
                            );
                            return;
                          }

                          showMySnackBar(
                            context: context,
                            message: "Login successful",
                            color: Colors.green,
                          );

                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushNamed(context, '/dashboard');
                          });
                        },
                        text: "Log in",
                        height: 12,
                        borderRadius: 12,
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign up",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/signup');
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
            ],
          );
        },
      ),
    );
  }
}
