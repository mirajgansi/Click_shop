import 'package:click_shop/features/order/domain/entities/order_entities.dart';

abstract interface class IDriverLocalDatabase {
  Future<void> cacheMyAssignedOrders(List<OrderEntity> orders);

  List<OrderEntity> getCachedMyAssignedOrders();

  Future<void> clear();
}

abstract interface class IDriverRemoteDatabase {
  Future<List<OrderEntity>> getMyAssignedOrders();
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
