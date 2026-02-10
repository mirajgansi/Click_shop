import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/driver/data/datasources/driver_datasource.dart';
import 'package:click_shop/features/order/data/model/order_hive_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final DriverLocalDatasourceProvider = Provider<DriverLocalDatasource>((ref) {
  final hiveService = ref.read(HiveServiceProvider);
  return DriverLocalDatasource(hiveService: hiveService);
});

class DriverLocalDatasource implements IDriverLocalDatabase {
  final HiveService _hiveService;

  DriverLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cacheMyAssignedOrders(List<OrderEntity> orders) async {
    final models = orders.map(OrderHiveModel.fromEntity).toList();
    await _hiveService.cacheDriverOrders(models);
  }

  @override
  List<OrderEntity> getCachedMyAssignedOrders() {
    final models = _hiveService.getDriverOrders();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> clear() async {
    await _hiveService.clearDriverOrders();
  }
}
