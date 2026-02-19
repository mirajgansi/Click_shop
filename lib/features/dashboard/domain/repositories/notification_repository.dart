import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:dartz/dartz.dart';

abstract interface class INotificationRepository {
  /// Fetch notifications (usually remote -> cache -> return)
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications({
    bool forceRefresh = false,
  });

  /// Unread count (remote if possible, fallback local)
  Future<Either<Failure, int>> getUnreadCount({bool forceRefresh = false});

  /// Mark one notification read (remote + local)
  Future<Either<Failure, bool>> markNotificationRead(String id);

  /// Mark all read (remote + local)
  Future<Either<Failure, bool>> markAllNotificationsRead();

  /// Get locally cached notifications (no API)
  Future<Either<Failure, List<NotificationEntity>>> getCachedNotifications();

  /// Clear local cache
  Future<Either<Failure, bool>> clearNotificationsCache();
}
