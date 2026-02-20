import 'package:click_shop/core/services/notifications/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_settings_provider.dart';

// Call this when socket message arrives
final notificationRouterProvider = Provider((ref) {
  return NotificationRouter(ref);
});

class NotificationRouter {
  final Ref ref;
  NotificationRouter(this.ref);

  Future<void> onSocketMessage({
    required BuildContext context,
    required String title,
    required String body,
    String? payload,
  }) async {
    final enabled = ref.read(notificationEnabledProvider);

    if (enabled) {
      await LocalNotificationService.instance.showNotification(
        title: title,
        body: body,
        payload: payload,
      );
    } else {
      _showInAppToast(context, body);
    }
  }

  void _showInAppToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }
}
