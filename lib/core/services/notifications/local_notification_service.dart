import 'package:click_shop/core/navigation/nav_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _enabled = true;

  void setEnabled(bool value) async {
    _enabled = value;

    if (!value) {
      // Cancel any existing notifications
      await notificationsPlugin.cancelAll();
    }
  }

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'channel_id',
    'channel_name',

    description: 'channel_description',
    importance: Importance.max,
  );

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          handlePayloadNavigation(payload);
        }
      },
    );
    // Create Android channel (important)
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);

    _isInitialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_enabled) return;

    await initNotification();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'channel_description',
        icon: 'happy',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}

void handleNotificationNavigation(Map<String, dynamic> data) {
  final type = data['type']?.toString();

  // ✅ orderId is nested inside "data"
  final nested = data['data'];
  final orderId = (nested is Map) ? nested['orderId']?.toString() : null;

  if (orderId == null || orderId.isEmpty) return;

  // ✅ types that should open order detail
  const openOrderTypes = {'order', 'driver_assigned', 'order_status'};
  if (type != null && openOrderTypes.contains(type)) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed('/order-detail', arguments: orderId);
    });
  }
}

void handlePayloadNavigation(String payload) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigatorKey.currentState?.pushNamed('/order-detail', arguments: payload);
  });
}
