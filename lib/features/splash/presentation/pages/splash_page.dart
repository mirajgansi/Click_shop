import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStartScreen extends ConsumerStatefulWidget {
  const AppStartScreen({super.key});

  @override
  ConsumerState<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends ConsumerState<AppStartScreen> {
  bool _ran = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ran) return;
    _ran = true;

    Future.microtask(() async {
      await ref.read(AuthViewModelProvider.notifier).getCurrentUser();

      final authState = ref.read(AuthViewModelProvider);
      final user = authState.user;

      if (!mounted) return;

      if (user == null) {
        Navigator.pushReplacementNamed(context, "/login");
        return;
      }

      final role = (user.role ?? "").toLowerCase();

      if (role == "driver") {
        Navigator.pushReplacementNamed(context, "/driver");
      } else {
        Navigator.pushReplacementNamed(context, "/dashboard");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
