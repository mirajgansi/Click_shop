// lib/features/driver/presentation/state/driver_state.dart
import 'package:click_shop/features/driver/domain/entities/driver_order_stats.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';

enum DriverStatus { initial, loading, loaded, updating, error }

class DriverState {
  final DriverStatus status;
  final List<OrderEntity> orders;
  final DriverOrderStats stats;
  final String? errorMessage;

  const DriverState({
    this.status = DriverStatus.initial,
    this.orders = const [],
    this.stats = const DriverOrderStats(totalAssigned: 0, totalDelivered: 0),
    this.errorMessage,
  });

  DriverState copyWith({
    DriverStatus? status,
    List<OrderEntity>? orders,
    DriverOrderStats? stats,
    String? errorMessage,
  }) {
    return DriverState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }
}
