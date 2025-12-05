import 'package:click_shop/screens/frogotpassword_screen.dart';
import 'package:click_shop/screens/onboarding.dart';
import 'package:click_shop/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Dashboard(),
        '/login': (context) => const LoginScreen(),
        '/forgotpassword': (context) => const FrogotpasswordScreen(),
      },
    );
  }
}
