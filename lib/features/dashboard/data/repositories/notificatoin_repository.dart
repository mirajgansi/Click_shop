import 'dart:async';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/dashboard/data/daatasources/local/notification_local_datasource.dart';
import 'package:click_shop/features/dashboard/data/daatasources/notification_datasource.dart';
import 'package:click_shop/features/dashboard/data/daatasources/remote/notification_remote_datasource.dart';
import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';

import 'package:click_shop/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final local = ref.watch(notificationLocalDatasourceProvider);
  final remote = ref.read(notificationRemoteDataSourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return NotificationRepository(
    localDataSource: local,
    remoteDataSource: remote,
    networkInfo: networkInfo,
  );
});

class NotificationRepository implements INotificationRepository {
  final INotificationLocalDataSource _local;
  final INotificationRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  NotificationRepository({
    required INotificationLocalDataSource localDataSource,
    required INotificationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _local = localDataSource,
       _remote = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications({
    bool forceRefresh = false,
  }) async {
    // 1) return cache fast (unless forceRefresh)
    if (!forceRefresh) {
      try {
        final cached = await _local.getNotifications();
        if (cached.isNotEmpty) {
          // refresh silently
          unawaited(_refreshNotifications());
          return Right(cached.map((e) => e.toEntity()).toList());
        }
      } catch (_) {}
    }

    if (await _networkInfo.isConnected) {
      try {
        final apiList = await _remote.getMyNotifications();

        // cache in hive
        final hiveList = apiList.map((e) => e.toHiveModel()).toList();
        await _local.cacheNotifications(hiveList);

        return Right(apiList.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        // fallback to cache if available
        final fallback = await _safeGetCached();
        if (fallback != null) return Right(fallback);

        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch notifications',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final fallback = await _safeGetCached();
        if (fallback != null) return Right(fallback);

        return Left(ApiFailure(message: e.toString()));
      }
    }

    // 3) offline -> cache only
    final cached = await _safeGetCached();
    if (cached != null) return Right(cached);

    return const Left(LocalDatabaseFailure(message: "No cached notifications"));
  }

  Future<void> _refreshNotifications() async {
    if (!await _networkInfo.isConnected) return;
    try {
      final apiList = await _remote.getMyNotifications();
      await _local.cacheNotifications(
        apiList.map((e) => e.toHiveModel()).toList(),
      );
    } catch (_) {}
  }

  Future<List<NotificationEntity>?> _safeGetCached() async {
    try {
      final cached = await _local.getNotifications();
      if (cached.isEmpty) return null;
      return cached.map((e) => e.toEntity()).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    bool forceRefresh = false,
  }) async {
    // fast local if not forceRefresh
    if (!forceRefresh) {
      try {
        final localCount = await _local.getUnreadCount();
        if (localCount >= 0) {
          unawaited(_refreshUnreadCount());
          return Right(localCount);
        }
      } catch (_) {}
    }

    if (await _networkInfo.isConnected) {
      try {
        final count = await _remote.getUnreadCount();
        // optional: keep local consistent by refreshing notifications
        unawaited(_refreshNotifications());
        return Right(count);
      } on DioException catch (e) {
        // fallback local
        try {
          final localCount = await _local.getUnreadCount();
          return Right(localCount);
        } catch (_) {
          return Left(
            ApiFailure(
              message:
                  e.response?.data['message'] ?? 'Failed to fetch unread count',
              statusCode: e.response?.statusCode,
            ),
          );
        }
      } catch (e) {
        try {
          final localCount = await _local.getUnreadCount();
          return Right(localCount);
        } catch (_) {
          return Left(ApiFailure(message: e.toString()));
        }
      }
    }

    // offline
    try {
      final localCount = await _local.getUnreadCount();
      return Right(localCount);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<void> _refreshUnreadCount() async {
    if (!await _networkInfo.isConnected) return;
    try {
      // no local write needed; you can refresh notifications for accuracy
      await _remote.getUnreadCount();
    } catch (_) {}
  }

  @override
  Future<Either<Failure, bool>> markNotificationRead(String id) async {
    if (id.isEmpty) {
      return const Left(ApiFailure(message: "Notification id is required"));
    }

    // optimistic local update (UI feels instant)
    try {
      await _local.markNotificationRead(id);
    } catch (_) {}

    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remote.markNotificationRead(id);
        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to mark as read',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    // offline: local change done, but server not updated
    return const Left(LocalDatabaseFailure(message: "No internet connection"));
  }

  @override
  Future<Either<Failure, bool>> markAllNotificationsRead() async {
    // optimistic local
    try {
      await _local.markAllNotificationsRead();
    } catch (_) {}

    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remote.markAllNotificationsRead();
        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to mark all as read',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return const Left(LocalDatabaseFailure(message: "No internet connection"));
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>>
  getCachedNotifications() async {
    try {
      final cached = await _local.getNotifications();
      return Right(cached.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> clearNotificationsCache() async {
    try {
      await _local.clearNotifications();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
