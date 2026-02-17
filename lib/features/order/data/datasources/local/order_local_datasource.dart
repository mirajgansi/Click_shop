import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/order/data/datasources/order_datasource.dart';
import 'package:click_shop/features/order/data/model/order_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderLocalDatasourceProvider = Provider<OrderLocalDatasource>((ref) {
  final hiveService = ref.watch(HiveServiceProvider);
  return OrderLocalDatasource(hiveService: hiveService);
});

class OrderLocalDatasource implements IOrderLocalDatasource {
  final HiveService _hiveService;

  OrderLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cacheMyOrders(List<OrderHiveModel> orders) async {
    try {
      await _hiveService.cacheMyOrders(orders);
    } catch (e) {
      // silently fail (not recommended for production)
    }
  }

  @override
  Future<List<OrderHiveModel>> getCachedMyOrders() async {
    try {
      return await _hiveService.getCachedMyOrders();
    } catch (e) {
      return []; // return empty list instead of crash
    }
  }

  @override
  Future<void> cacheOrder(OrderHiveModel order) async {
    try {
      await _hiveService.cacheOrder(order);
    } catch (e) {
      // ignore
    }
  }

  @override
  Future<OrderHiveModel?> getCachedOrderById(String id) async {
    try {
      return await _hiveService.getCachedOrderById(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearMyOrders() async {
    try {
      await _hiveService.clearMyOrders();
    } catch (e) {}
  }
}
