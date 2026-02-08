import 'package:click_shop/features/order/data/model/order_api_model.dart';

abstract class IOrderRemoteDatasource {
  Future<bool> createOrderFromCart();

  Future<List<OrderApiModel>> getMyOrders();
  Future<OrderApiModel> getOrderById(String id);
  Future<bool> cancelMyOrder(String id);
  Future<List<OrderApiModel>> getDriverOrders();
}
