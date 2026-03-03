import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:click_shop/features/order/presentation/pages/order_detail_page.dart';
import 'package:click_shop/features/order/presentation/state/order_state.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fake notifier so Riverpod can run without real late dependencies.
class FakeOrderViewModel extends OrderViewModel {
  FakeOrderViewModel(this._initialState);

  final OrderState _initialState;

  int getByIdCalls = 0;
  int cancelCalls = 0;

  OrderEntity? orderToReturn;
  String? errorAfterCancel;

  @override
  OrderState build() => _initialState;

  @override
  Future<void> getOrderById(String orderId) async {
    getByIdCalls++;

    state = state.copyWith(
      isLoading: false,
      errorMessage: null,
      selectedOrder: orderToReturn,
    );
  }

  @override
  Future<void> cancelMyOrder(String orderId) async {
    cancelCalls++;

    state = state.copyWith(errorMessage: errorAfterCancel);
  }
}

OrderEntity makeOrder({
  required String id,
  required OrderStatus status,
  PaymentStatus paymentStatus = PaymentStatus.unpaid,
}) {
  return OrderEntity(
    id: id,
    userId: 'u1',
    items: const [
      OrderItemEntity(
        productId: 'p1',
        name: 'Item 1',
        price: 100,
        quantity: 1,
        lineTotal: 100,
      ),
    ],
    subtotal: 100,
    shippingFee: 0,
    total: 100,
    status: status,
    paymentStatus: paymentStatus,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Widget wrapWithVm(FakeOrderViewModel vm, Widget child) {
  return ProviderScope(
    overrides: [orderViewModelProvider.overrideWith(() => vm)],
    child: MaterialApp(home: child),
  );
}

class NoopGetByIdOrderViewModel extends FakeOrderViewModel {
  NoopGetByIdOrderViewModel(super.initialState);

  @override
  Future<void> getOrderById(String orderId) async {
    // do nothing -> keep errorMessage from initial state
  }
}

Future<void> pumpDetail(
  WidgetTester tester,
  FakeOrderViewModel vm, {
  required String orderId,
}) async {
  await tester.pumpWidget(wrapWithVm(vm, OrderDetailPage(orderId: orderId)));
  await tester.pump();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('calls getOrderById on init', (tester) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = makeOrder(id: '1', status: OrderStatus.pending);

    await pumpDetail(tester, vm, orderId: '1');

    expect(vm.getByIdCalls, 1);
  });

  testWidgets('shows error message when state.errorMessage != null', (
    tester,
  ) async {
    final vm = NoopGetByIdOrderViewModel(
      const OrderState(errorMessage: 'Something bad'),
    );

    await tester.pumpWidget(
      wrapWithVm(vm, const OrderDetailPage(orderId: '1')),
    );

    await tester.pump(); // build frame
    await tester.pump(); // flush microtask (noop, so state unchanged)

    expect(find.text('Something bad'), findsOneWidget);
  });

  testWidgets('shows "Order not found" when selectedOrder is null', (
    tester,
  ) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = null;

    await pumpDetail(tester, vm, orderId: '404');

    expect(find.text('Order not found'), findsOneWidget);
  });

  testWidgets('renders order details when selectedOrder exists', (
    tester,
  ) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = makeOrder(id: 'A1', status: OrderStatus.pending);

    await pumpDetail(tester, vm, orderId: 'A1');

    expect(find.text('Order Details'), findsOneWidget);
    expect(find.textContaining('Order #A1'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.textContaining('Subtotal'), findsOneWidget);
    expect(find.textContaining('Total'), findsOneWidget);
  });

  testWidgets('pending order -> shows Cancel Order button', (tester) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = makeOrder(id: 'P1', status: OrderStatus.pending);

    await pumpDetail(tester, vm, orderId: 'P1');

    expect(find.text('Cancel Order'), findsOneWidget);
  });

  testWidgets('non-pending order -> shows Locked button', (tester) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = makeOrder(id: 'S1', status: OrderStatus.shipped);

    await pumpDetail(tester, vm, orderId: 'S1');

    // Scoped finder: only the bottom button text
    final lockedOnButton = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.text('Locked'),
    );

    expect(lockedOnButton, findsOneWidget);
  });

  testWidgets('tap Locked -> opens snackbar text path (no dialog)', (
    tester,
  ) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = makeOrder(id: 'S1', status: OrderStatus.shipped);

    await pumpDetail(tester, vm, orderId: 'S1');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); 
    expect(find.text('Cancel Order?'), findsNothing);
  });

  testWidgets(
    'tap Cancel Order -> dialog shows; tap No closes; no cancel call',
    (tester) async {
      final vm = FakeOrderViewModel(const OrderState());
      vm.orderToReturn = makeOrder(id: 'P1', status: OrderStatus.pending);

      await pumpDetail(tester, vm, orderId: 'P1');

      await tester.tap(find.text('Cancel Order'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Order?'), findsOneWidget);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Order?'), findsNothing);
      expect(vm.cancelCalls, 0);
    },
  );

  testWidgets(
    'tap Cancel Order -> dialog Yes -> calls cancelMyOrder then getOrderById',
    (tester) async {
      final vm = FakeOrderViewModel(const OrderState());
      vm.orderToReturn = makeOrder(id: 'P1', status: OrderStatus.pending);

      await pumpDetail(tester, vm, orderId: 'P1');

      await tester.tap(find.text('Cancel Order'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes, cancel'));
      await tester.pump(); // start async actions
      await tester.pumpAndSettle();

      expect(vm.cancelCalls, 1);
      expect(
        vm.getByIdCalls,
        greaterThanOrEqualTo(2),
      ); // init + finally refresh
    },
  );

  testWidgets('after cancel error -> cancel called (error path executed)', (
    tester,
  ) async {
    final vm = FakeOrderViewModel(const OrderState());
    vm.orderToReturn = makeOrder(id: 'P1', status: OrderStatus.pending);
    vm.errorAfterCancel = 'Cancel failed';

    await pumpDetail(tester, vm, orderId: 'P1');

    await tester.tap(find.text('Cancel Order'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes, cancel'));
    await tester.pump(); // run async
    await tester.pump(); // flush microtasks

    expect(vm.cancelCalls, 1);
    expect(vm.getByIdCalls, greaterThanOrEqualTo(2)); // init + finally refresh
  });
}
