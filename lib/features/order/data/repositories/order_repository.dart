import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/order/data/daatasources/order_datasource.dart';
import 'package:click_shop/features/order/data/daatasources/remote/order_remote_datasource.dart';
import 'package:click_shop/features/order/data/model/order_api_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final remote = ref.read(orderRemoteDatasourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return OrderRepositoryImpl(
    remoteDatasource: remote,
    networkInfo: networkInfo,
  );
});

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDatasource _remote;
  final NetworkInfo _networkInfo;

  OrderRepositoryImpl({
    required IOrderRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remote = remoteDatasource,
       _networkInfo = networkInfo;

  Failure _noInternet() =>
      LocalDatabaseFailure(message: "No internet connection");

  @override
  Future<Either<Failure, bool>> createOrderFromCart() async {
    if (!await _networkInfo.isConnected) {
      return Left(LocalDatabaseFailure(message: "No internet connection"));
    }

    try {
      final ok = await _remote.createOrderFromCart();

      if (ok) {
        return Left(LocalDatabaseFailure(message: "Failed to create order"));
      }

      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    if (!await _networkInfo.isConnected) return Left(_noInternet());

    try {
      final models = await _remote.getMyOrders();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (!await _networkInfo.isConnected) return Left(_noInternet());

    try {
      final model = await _remote.getOrderById(orderId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelMyOrder(String orderId) async {
    if (!await _networkInfo.isConnected) return Left(_noInternet());

    try {
      final ok = await _remote.cancelMyOrder(orderId);
      if (!ok) {
        return Left(LocalDatabaseFailure(message: "Failed to cancel order"));
      }
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getDriverOrders() {
    // TODO: implement getDriverOrders
    throw UnimplementedError();
  }

  // @override
  // Future<Either<Failure, List<OrderEntity>>> getDriverOrders() async {
  //   if (!await _networkInfo.isConnected) return Left(_noInternet());

  //   try {
  //     final models = await _remote.get();
  //     final entities = models.map((m) => m.toEntity()).toList();
  //     return Right(entities);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }
}
