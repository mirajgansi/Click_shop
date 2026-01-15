import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../screens/bottom_navigation_screen.dart';

class AppStartScreen extends ConsumerStatefulWidget {
  const AppStartScreen({super.key});

  @override
  ConsumerState<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends ConsumerState<AppStartScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final session = ref.read(UserSessionServiceProvider);
      final isLoggedIn = session.isLoggedIn(); // ✅ rename method properly

      if (isLoggedIn) {
        AppRoutes.pushReplacement(context, const DashboardScreen());
      } else {
        AppRoutes.pushReplacement(context, const Onboarding());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
