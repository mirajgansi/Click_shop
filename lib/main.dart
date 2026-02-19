import 'package:click_shop/app/theme/app_theme.dart';
import 'package:click_shop/app/theme/effective_theme_mode_provider.dart';
import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/driver/presentation/pages/driver_home_page.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_navigation_screen.dart';
import 'package:click_shop/features/auth/presentation/pages/frogotpassword_page.dart';
import 'package:click_shop/features/auth/presentation/pages/login_page.dart';
import 'package:click_shop/features/auth/presentation/pages/signup_page.dart';
import 'package:click_shop/features/splash/presentation/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Local notifications plugin (GLOBAL)
final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

// ✅ Android channel (GLOBAL)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final sharedPrefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp();

  // ✅ background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ init local notifications
  await fln.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // ✅ create channel
  await fln
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.requestPermission();

  // ✅ Foreground messages => show notification bar using local notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;

    fln.show(
      id: n.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  });

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
