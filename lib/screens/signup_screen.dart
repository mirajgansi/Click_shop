import 'package:click_shop/widgets/my_button_widgets.dart';
import 'package:click_shop/widgets/my_text_field_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signup',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter your credentials to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 20),
                MyTextFieldWidgets(
                  controller: emailController,
                  hintText: "Jhon Doe",
                  text: "Username",
                ),
                SizedBox(height: 10),
                MyTextFieldWidgets(
                  controller: emailController,
                  hintText: "example600@gmail.com",
                  text: "Email",
                ),
                SizedBox(height: 10),
                MyTextFieldWidgets(
                  controller: passwordController,
                  hintText: "*******",
                  text: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextFieldWidgets(
                  controller: passwordController,
                  hintText: "*******",
                  text: "Confirm Password",
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Text(
                  "By continuing you agree to our Terms of Service and Privacy Policy.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                SizedBox(height: 20),

                MyButtonWidgets(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  text: "Sign up",
                ),
                SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an accont? ",
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
                            fontWeight: FontWeight.bold,
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
    );
  }
}
