// lib/features/driver/domain/usecases/get_driver_order_stats_usecase.dart
import 'package:click_shop/core/error/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:click_shop/features/driver/domain/entities/driver_order_stats.dart';
import 'package:click_shop/features/driver/domain/usecases/get_my_assiged_orders_usecase.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:dartz/dartz.dart';

final getDriverOrderStatsUsecaseProvider = Provider<GetDriverOrderStatsUsecase>(
  (ref) {
    return GetDriverOrderStatsUsecase(
      getMyAssignedOrders: ref.read(getMyAssignedOrdersUsecaseProvider),
    );
  },
);

class GetDriverOrderStatsUsecase {
  final GetMyAssignedOrdersUsecase getMyAssignedOrders;

  GetDriverOrderStatsUsecase({required this.getMyAssignedOrders});

  Future<Either<Failure, DriverOrderStats>> call() async {
    final result = await getMyAssignedOrders();

    return result.map((orders) {
      final totalAssigned = orders.length;

      final totalDelivered = orders.where((o) {
        return o.status == OrderStatus.delivered;
      }).length;

      return DriverOrderStats(
        totalAssigned: totalAssigned,
        totalDelivered: totalDelivered,
      );
    });
  }
}
