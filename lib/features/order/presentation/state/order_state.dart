import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:equatable/equatable.dart';

class OrderState extends Equatable {
  final bool isLoading;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final String? errorMessage;
  final bool actionSuccess;

  const OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
    this.actionSuccess = false,
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    String? errorMessage,
    bool? actionSuccess,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage,
      actionSuccess: actionSuccess ?? this.actionSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    orders,
    selectedOrder,
    errorMessage,
    actionSuccess,
  ];
}
