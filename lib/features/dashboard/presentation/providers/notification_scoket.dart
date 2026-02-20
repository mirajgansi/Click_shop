import 'package:click_shop/core/navigation/nav_key.dart';
import 'package:click_shop/features/dashboard/presentation/providers/notification_settings_provider.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_notification_banner.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:click_shop/core/providers/socket_service_provider.dart';
import 'package:click_shop/features/dashboard/presentation/view_model/notification_view_model.dart';

final socketNotificationBridgeProvider = Provider<void>((ref) {
  ref.listen(socketNotificationStreamProvider, (prev, next) {
    next.whenData((data) {
      // 1) Update state + badge list
      ref
          .read(notificationViewModelProvider.notifier)
          .onSocketNotification(data);

      // 2) If notifications are OFF -> show in-app banner
      final enabled = ref.read(notificationEnabledProvider);
      if (!enabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final overlay = navigatorKey.currentState?.overlay;
          if (overlay == null) return;

          InAppNotification.showGlobal(
            title: (data is Map && data['title'] != null)
                ? '${data['title']}'
                : 'New notification',
            message: (data is Map && data['message'] != null)
                ? '${data['message']}'
                : '',
          );
        });
      }
    });
  });
});
