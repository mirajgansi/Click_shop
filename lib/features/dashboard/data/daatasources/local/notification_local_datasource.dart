import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/dashboard/data/daatasources/notification_datasource.dart';
import 'package:click_shop/features/dashboard/data/model/notification_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationLocalDatasourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
      final hiveService = ref.read(HiveServiceProvider);
      return NotificationLocalDataSource(hiveService: hiveService);
    });

class NotificationLocalDataSource implements INotificationLocalDataSource {
  final HiveService _hiveService;

  NotificationLocalDataSource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cacheNotifications(
    List<NotificationHiveModel> notifications,
  ) async {
    await _hiveService.cacheNotifications(notifications);
  }

  @override
  Future<List<NotificationHiveModel>> getNotifications() async {
    return _hiveService.getNotificationsFromCache();
  }

  @override
  Future<int> getUnreadCount() async {
    return _hiveService.getUnreadCountFromCache();
  }

  @override
  Future<void> markNotificationRead(String id) async {
    if (id.isEmpty) return;
    await _hiveService.markNotificationReadLocal(id);
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await _hiveService.markAllNotificationsReadLocal();
  }

  @override
  Future<void> clearNotifications() async {
    await _hiveService.clearNotifications();
  }
}
