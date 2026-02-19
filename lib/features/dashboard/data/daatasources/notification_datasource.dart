import 'package:click_shop/features/dashboard/data/model/notification_api_model.dart';
import 'package:click_shop/features/dashboard/data/model/notification_hive_model.dart';

/// ================= LOCAL =================
abstract interface class INotificationLocalDataSource {
  Future<void> cacheNotifications(List<NotificationHiveModel> notifications);

  Future<List<NotificationHiveModel>> getNotifications();

  Future<int> getUnreadCount();

  Future<void> markNotificationRead(String id);

  Future<void> markAllNotificationsRead();

  Future<void> clearNotifications();
}

abstract interface class INotificationRemoteDataSource {
  Future<List<NotificationApiModel>> getMyNotifications();

  Future<int> getUnreadCount();

  Future<bool> markNotificationRead(String id);

  Future<bool> markAllNotificationsRead();

  Future<bool> createNotification(NotificationApiModel notification);
}
