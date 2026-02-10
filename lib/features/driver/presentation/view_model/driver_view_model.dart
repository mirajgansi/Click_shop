import 'package:click_shop/features/driver/domain/usecases/get_my_assiged_orders_usecase.dart';
import 'package:click_shop/features/driver/domain/usecases/update_ordeR_status._useccase.dart';
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverViewModelProvider = NotifierProvider<DriverViewModel, DriverState>(
  () => DriverViewModel(),
);

class DriverViewModel extends Notifier<DriverState> {
  late final GetMyAssignedOrdersUsecase _getMyOrders;
  late final UpdateOrderStatusUsecase _updateStatus;

  @override
  DriverState build() {
    _getMyOrders = ref.read(getMyAssignedOrdersUsecaseProvider);
    _updateStatus = ref.read(updateOrderStatusUsecaseProvider);
    return const DriverState();
  }

  Future<void> loadMyOrders() async {
    state = state.copyWith(status: DriverStatus.loading, errorMessage: null);

    final result = await _getMyOrders();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: DriverStatus.error,
          errorMessage: failure.message,
        );
      },
      (orders) {
        state = state.copyWith(
          status: DriverStatus.loaded,
          orders: orders,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    bool refreshAfter = true,
  }) async {
    state = state.copyWith(status: DriverStatus.updating, errorMessage: null);

    final result = await _updateStatus(orderId: orderId, status: status);

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: DriverStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) async {
        // ✅ optimistic update locally
        final updated = state.orders.map((o) {
          if (o.id == orderId) {
            return OrderEntity(
              id: o.id,
              userId: o.userId,
              items: o.items,
              subtotal: o.subtotal,
              shippingFee: o.shippingFee,
              total: o.total,
              status: o.status, // keep as is unless you map string->enum here
              paymentStatus: o.paymentStatus,
              shippingAddress: o.shippingAddress,
              notes: o.notes,
              driverId: o.driverId,
              driverName: o.driverName,
              createdAt: o.createdAt,
              updatedAt: o.updatedAt,
            );
          }
          return o;
        }).toList();

        state = state.copyWith(status: DriverStatus.loaded, orders: updated);

        if (refreshAfter) {
          await loadMyOrders();
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
