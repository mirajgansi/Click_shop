import 'package:click_shop/core/services/hive_service.dart';
import 'package:click_shop/screens/bottom_navigation_screen.dart';
import 'package:click_shop/features/auth/presentation/pages/frogotpassword_screen.dart';
import 'package:click_shop/screens/onboarding.dart';
import 'package:click_shop/features/auth/presentation/pages/login_screen.dart';
import 'package:click_shop/features/auth/presentation/pages/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboarding(),
        '/login': (context) => const LoginPage(),
        '/forgotpassword': (context) => const FrogotpasswordScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
