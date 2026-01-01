import 'package:click_shop/common/my_snack_bar.dart';
import 'package:click_shop/core/widgets/my_button_widgets.dart';
import 'package:click_shop/core/widgets/my_text_field_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
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
                          controller: usernameController,
                          hintText: "John Doe",
                          text: "Username",
                        ),

                        const SizedBox(height: 10),

                        MyTextFieldWidgets(
                          controller: emailController,
                          hintText: "example600@gmail.com",
                          text: "Email",
                        ),

                        const SizedBox(height: 10),

                        MyTextFieldWidgets(
                          controller: passwordController,
                          hintText: "*******",
                          text: "Password",
                          obscureText: true,
                        ),

                        const SizedBox(height: 10),

                        MyTextFieldWidgets(
                          controller: confirmPasswordController,
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
                            final username = usernameController.text.trim();
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final confirmPassword = confirmPasswordController
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

                            Future.delayed(const Duration(seconds: 1), () {
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
            ],
          );
        },
      ),
    );
  }
}
