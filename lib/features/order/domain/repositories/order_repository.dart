import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:dartz/dartz.dart';

abstract interface class IOrderRepository {
  // user
  Future<Either<Failure, bool>> createOrderFromCart(
    Map<String, dynamic> shippingJson,
  );
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, bool>> cancelMyOrder(String orderId);

  // driver
  Future<Either<Failure, List<OrderEntity>>> getDriverOrders();
}
