import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:dartz/dartz.dart';

abstract interface class IDriverRepository {
  Future<Either<Failure, List<OrderEntity>>> getMyAssignedOrders();

  // PATCH /api/orders/driver/:id/status
  Future<Either<Failure, bool>> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
