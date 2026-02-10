import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/driver/data/datasources/driver_datasource.dart';
import 'package:click_shop/features/driver/data/datasources/local/driver_local_datasource.dart';
import 'package:click_shop/features/driver/data/datasources/remote/driver_remote_datasource.dart';

import 'package:click_shop/features/driver/domain/repositories/driver_repository.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final driverRepositoryProvider = Provider<IDriverRepository>((ref) {
  final local = ref.watch(DriverLocalDatasourceProvider); // your local provider
  final remote = ref.read(
    driverRemoteDataSourceProvider,
  ); // your remote provider
  final networkInfo = ref.read(NetworkInfoProvider);

  return DriverRepository(
    driverLocalDatabase: local,
    driverRemoteDatabase: remote,
    networkInfo: networkInfo,
  );
});

class DriverRepository implements IDriverRepository {
  final IDriverLocalDatabase _local;
  final IDriverRemoteDatabase _remote;
  final NetworkInfo _networkInfo;

  DriverRepository({
    required IDriverLocalDatabase driverLocalDatabase,
    required IDriverRemoteDatabase driverRemoteDatabase,
    required NetworkInfo networkInfo,
  }) : _local = driverLocalDatabase,
       _remote = driverRemoteDatabase,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyAssignedOrders() async {
    if (await _networkInfo.isConnected) {
      try {
        final orders = await _remote.getMyAssignedOrders();

        await _local.cacheMyAssignedOrders(orders);
        return Right(orders);
      } on DioException catch (e) {
        final cached = _local.getCachedMyAssignedOrders();
        if (cached.isNotEmpty) return Right(cached);

        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to load driver orders',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _local.getCachedMyAssignedOrders();
        if (cached.isNotEmpty) return Right(cached);

        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final cached = _local.getCachedMyAssignedOrders();
        if (cached.isNotEmpty) return Right(cached);

        return const Left(
          LocalDatabaseFailure(message: "No cached driver orders"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remote.updateOrderStatus(
          orderId: orderId,
          status: status,
        );
        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to update status',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        LocalDatabaseFailure(
          message: "No internet. Can't update status offline.",
        ),
      );
    }
  }
}
