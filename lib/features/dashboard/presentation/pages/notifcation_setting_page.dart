import 'package:click_shop/core/services/notifications/local_notification_service.dart';
import 'package:click_shop/features/dashboard/presentation/providers/notification_settings_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final ok =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission not granted")));
      }
      ref.read(notificationEnabledProvider.notifier).state = false;
      return;
    }
    LocalNotificationService.instance.setEnabled(true);

    ref.read(notificationEnabledProvider.notifier).state = true;
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Notifications enabled")));
    }
    LocalNotificationService.instance.setEnabled(true);
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    // Optional (if you use topics)
    // await FirebaseMessaging.instance.unsubscribeFromTopic("general");

    ref.read(notificationEnabledProvider.notifier).state = false;

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Notifications disabled")));
    }
    LocalNotificationService.instance.setEnabled(false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final enabled = ref.watch(notificationEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Enable notifications",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  enabled
                      ? "You will receive alerts for new updates."
                      : "You won’t receive alerts.",
                ),
                secondary: const Icon(Icons.notifications),
                value: enabled,
                onChanged: (v) async {
                  if (v) {
                    await _enable(context, ref);
                  } else {
                    await _disable(context, ref);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
