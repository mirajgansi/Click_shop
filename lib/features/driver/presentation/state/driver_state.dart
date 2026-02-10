import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:equatable/equatable.dart';

enum DriverStatus { initial, loading, loaded, updating, error }

class DriverState extends Equatable {
  final DriverStatus status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const DriverState({
    this.status = DriverStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  DriverState copyWith({
    DriverStatus? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return DriverState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
