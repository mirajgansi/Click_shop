import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/order/data/datasources/order_datasource.dart';
import 'package:click_shop/features/order/data/datasources/local/order_local_datasource.dart';
import 'package:click_shop/features/order/data/datasources/remote/order_remote_datasource.dart';
import 'package:click_shop/features/order/data/model/order_api_model.dart';
import 'package:click_shop/features/order/data/model/order_hive_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final remote = ref.read(orderRemoteDatasourceProvider);
  final local = ref.read(orderLocalDatasourceProvider); // ✅ local
  final networkInfo = ref.read(NetworkInfoProvider);

  return OrderRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
    networkInfo: networkInfo,
  );
});

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDatasource _remote;
  final IOrderLocalDatasource _local;
  final NetworkInfo _networkInfo;

  OrderRepositoryImpl({
    required IOrderRemoteDatasource remoteDatasource,
    required IOrderLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  }) : _remote = remoteDatasource,
       _local = localDatasource,
       _networkInfo = networkInfo;

  // -------------------- HELPERS (like ProductRepository) --------------------

  Future<Either<Failure, List<OrderEntity>>> _getCachedMyOrders() async {
    try {
      final cached = await _local.getCachedMyOrders();
      final entities = cached.map((h) => h.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, OrderEntity>> _getCachedOrderById(String id) async {
    try {
      final cached = await _local.getCachedOrderById(id);
      if (cached == null) {
        return const Left(
          LocalDatabaseFailure(message: "Order not found in cache"),
        );
      }
      return Right(cached.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  // -------------------- CREATE ORDER --------------------
  // create order needs internet (no offline fallback)
  @override
  Future<Either<Failure, bool>> createOrderFromCart(
    Map<String, dynamic> shippingJson,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final ok = await _remote.createOrderFromCart(shippingJson);
      if (!ok) {
        return const Left(ApiFailure(message: "Failed to create order"));
      }

      // optional: refresh my orders cache after create
      // try { await getMyOrders(); } catch (_) {}

      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // -------------------- GET MY ORDERS (like getAllProduct) --------------------
  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getMyOrders();
        final entities = models.map((m) => m.toEntity()).toList();

        final hiveModels = models
            .map((m) => OrderHiveModel.fromEntity(m.toEntity()))
            .toList();

        await _local.cacheMyOrders(hiveModels);

        return Right(entities);
      } catch (e) {
        // remote failed -> cached
        return _getCachedMyOrders();
      }
    } else {
      // offline -> cached
      return _getCachedMyOrders();
    }
  }

  // -------------------- GET ORDER BY ID (like getProductbyId) --------------------
  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remote.getOrderById(orderId);

        await _local.cacheOrder(OrderHiveModel.fromEntity(model.toEntity()));
        return Right(model.toEntity());
      } catch (e) {
        // remote failed -> cached order
        return _getCachedOrderById(orderId);
      }
    } else {
      return _getCachedOrderById(orderId);
    }
  }

  // -------------------- CANCEL ORDER --------------------
  // needs internet, but after success update cache
  @override
  Future<Either<Failure, bool>> cancelMyOrder(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final ok = await _remote.cancelMyOrder(orderId);
      if (!ok) {
        return const Left(ApiFailure(message: "Failed to cancel order"));
      }

      // optional: refresh cache after cancel
      // try { await getMyOrders(); } catch (_) {}

      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // -------------------- DRIVER ORDERS --------------------
  // If you want to cache driver orders too, add methods in local datasource.
  @override
  Future<Either<Failure, List<OrderEntity>>> getDriverOrders() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final models = await _remote.getDriverOrders();
      final entities = models.map((m) => m.toEntity()).toList();

      // If you added cacheDriverOrders in local datasource, do:
      // await _local.cacheDriverOrders(models.map((m) => m.toHiveModel()).toList());

      return Right(entities);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
