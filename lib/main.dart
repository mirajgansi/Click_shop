import 'package:click_shop/app/theme/app_theme.dart';
import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/driver/presentation/pages/driver_home_page.dart';
import 'package:click_shop/features/splash/presentation/pages/splash_page.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_navigation_screen.dart';
import 'package:click_shop/features/auth/presentation/pages/frogotpassword_page.dart';
import 'package:click_shop/features/auth/presentation/pages/login_page.dart';
import 'package:click_shop/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [SharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const AppStartScreen(),
        '/login': (context) => const LoginPage(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/driver': (context) => const DriverHomePage(),
      },
    );
  }
}
