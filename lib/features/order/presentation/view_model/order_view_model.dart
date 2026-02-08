import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/order/domain/usecases/cancel_my_order_usecase.dart';
import 'package:click_shop/features/order/domain/usecases/create_order_from_cart_usecase.dart';
import 'package:click_shop/features/order/domain/usecases/get_my_order_usecase.dart';

import 'package:click_shop/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:click_shop/features/order/presentation/state/order_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(
  OrderViewModel.new,
);

class OrderViewModel extends Notifier<OrderState> {
  late final CreateOrderFromCartUsecase _createOrderFromCartUsecase;
  late final GetMyOrdersUsecase _getMyOrdersUsecase;
  late final GetOrderByIdUsecase _getOrderByIdUsecase;
  late final CancelMyOrderUsecase _cancelMyOrderUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  // late final GetDriverOrdersUsecase _getDriverOrdersUsecase;

  @override
  OrderState build() {
    // init usecases from providers
    _createOrderFromCartUsecase = ref.read(createOrderFromCartUsecaseProvider);
    _getMyOrdersUsecase = ref.read(getMyOrdersUsecaseProvider);
    _getOrderByIdUsecase = ref.read(getOrderByIdUsecaseProvider);
    _cancelMyOrderUsecase = ref.read(cancelMyOrderUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);

    // _getDriverOrdersUsecase = ref.read(getDriverOrdersUsecaseProvider);

    // initial state
    return const OrderState();
  }

  Future<void> loadCurrentUser() async {
    final res = await _getCurrentUserUsecase();
    res.fold((_) {}, (user) {
      // store user in state if you want
      state = state.copyWith(currentUser: user);
    });
  }

  // ================= CREATE ORDER =================
  Future<void> createOrderFromCart(Map<String, dynamic> shippingJson) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _createOrderFromCartUsecase(
      CreateOrderParams(shippingJson),
    );

    res.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (_) => state = state.copyWith(isLoading: false, actionSuccess: true),
    );
  }

  // ================= GET MY ORDERS =================
  Future<void> getMyOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getMyOrdersUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (orders) {
        state = state.copyWith(isLoading: false, orders: orders);
      },
    );
  }

  // ================= GET ORDER BY ID =================
  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getOrderByIdUsecase(
      GetOrderByIdParams(orderId: orderId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (order) {
        state = state.copyWith(isLoading: false, selectedOrder: order);
      },
    );
  }

  // ================= CANCEL ORDER =================
  Future<void> cancelMyOrder(String orderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _cancelMyOrderUsecase(
      CancelOrderParams(orderId: orderId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) async {
        state = state.copyWith(isLoading: false, actionSuccess: true);

        // refresh orders after cancel
        await getMyOrders();
      },
    );
  }

  Future<void> loadMyOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getMyOrdersUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (orders) {
        state = state.copyWith(
          isLoading: false,
          orders: orders,
          errorMessage: null,
        );
      },
    );
  }

  // ================= DRIVER ORDERS =================
  // Future<void> getDriverOrders() async {
  //   state = state.copyWith(isLoading: true, errorMessage: null);

  //   final result = await _getDriverOrdersUsecase();

  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(isLoading: false, errorMessage: failure.message);
  //     },
  //     (orders) {
  //       state = state.copyWith(isLoading: false, orders: orders);
  //     },
  //   );
  // }

  // ================= RESET ACTION STATE =================
  void clearActionSuccess() {
    state = state.copyWith(actionSuccess: false);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
