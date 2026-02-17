import 'package:click_shop/features/order/data/model/order_api_model.dart';
import 'package:click_shop/features/order/data/model/order_hive_model.dart';

abstract class IOrderRemoteDatasource {
  Future<bool> createOrderFromCart(Map<String, dynamic> shippingJson);

  Future<List<OrderApiModel>> getMyOrders();
  Future<OrderApiModel> getOrderById(String id);
  Future<bool> cancelMyOrder(String id);
  Future<List<OrderApiModel>> getDriverOrders();
}

abstract class IOrderLocalDatasource {
  Future<void> cacheMyOrders(List<OrderHiveModel> orders);
  Future<List<OrderHiveModel>> getCachedMyOrders();

  Future<void> cacheOrder(OrderHiveModel order);
  Future<OrderHiveModel?> getCachedOrderById(String id);

  Future<void> clearMyOrders();
}
