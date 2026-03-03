import 'package:click_shop/core/services/notifications/local_notification_service.dart';
import 'package:click_shop/features/auth/domain/usecases/save_fcm_token_usecase.dart';
import 'package:click_shop/features/dashboard/presentation/providers/notification_settings_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final status = await Permission.notification.status;

    if (status.isPermanentlyDenied) {
      if (context.mounted) _showNotificationPermissionDialog(context);
      ref.read(notificationEnabledProvider.notifier).state = false;
      LocalNotificationService.instance.setEnabled(false);
      return;
    }

    if (!status.isGranted) {
      final res = await Permission.notification.request();
      if (!res.isGranted) {
        ref.read(notificationEnabledProvider.notifier).state = false;
        LocalNotificationService.instance.setEnabled(false);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission not granted")),
          );
        }
        return;
      }
    }

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final ok =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!ok) {
      ref.read(notificationEnabledProvider.notifier).state = false;
      LocalNotificationService.instance.setEnabled(false);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission not granted")));
      }
      return;
    }

    // 3) Get token and send to backend
    await _generateAndSendFcmToken(ref);

    // 4) Enable app-side notifications
    ref.read(notificationEnabledProvider.notifier).state = true;
    LocalNotificationService.instance.setEnabled(true);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Notifications enabled")));
    }
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    ref.read(notificationEnabledProvider.notifier).state = false;
    LocalNotificationService.instance.setEnabled(false);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Notifications disabled")));
    }
  }

  Future<void> _generateAndSendFcmToken(WidgetRef ref) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await ref
          .read(saveFcmTokenUsecaseProvider)
          .call(SaveFcmTokenParams(token: token));
    } catch (e) {
      debugPrint("FCM: ERROR => $e");
    }
  }

  void _showNotificationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Notifications"),
        content: const Text(
          "Notifications are permanently denied. Please enable them from App Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
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
