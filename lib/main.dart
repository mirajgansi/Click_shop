import 'package:click_shop/app/theme/app_theme.dart';
import 'package:click_shop/app/theme/effective_theme_mode_provider.dart';
import 'package:click_shop/app/theme/theme_mode_provider.dart';
import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/core/services/notifications/local_notification_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/driver/presentation/pages/driver_home_page.dart';
import 'package:click_shop/features/splash/presentation/pages/splash_page.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_navigation_screen.dart';
import 'package:click_shop/features/auth/presentation/pages/frogotpassword_page.dart';
import 'package:click_shop/features/auth/presentation/pages/login_page.dart';
import 'package:click_shop/features/auth/presentation/pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setupFCM() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? "Notification";
    final body = message.notification?.body ?? "";

    LocalNotificationService.instance.showNotification(
      title: title,
      body: body,
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await LocalNotificationService.instance.initNotification();

  final title = message.notification?.title ?? "Notification";
  final body = message.notification?.body ?? "";

  await LocalNotificationService.instance.showNotification(
    title: title,
    body: body,
    payload: message.data.isEmpty ? null : message.data.toString(),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  await Firebase.initializeApp();

  final sharedPrefs = await SharedPreferences.getInstance();

  await LocalNotificationService.instance.initNotification();
  await setupFCM();
  runApp(
    ProviderScope(
      overrides: [SharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(effectiveThemeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
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
