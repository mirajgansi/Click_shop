import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/my_order_screen.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/cart_sekeleton_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:click_shop/features/order/presentation/pages/order_detail_page.dart';
import 'package:click_shop/features/order/presentation/state/order_state.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';
import 'package:click_shop/features/order/presentation/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod needs a real Notifier instance, not a Mock.
class FakeOrderViewModel extends OrderViewModel {
  FakeOrderViewModel(this._initialState);

  final OrderState _initialState;

  int loadCalls = 0;
  int getByIdCalls = 0;

  @override
  OrderState build() => _initialState;

  @override
  Future<void> loadMyOrders() async {
    loadCalls++;
  }

  // ✅ IMPORTANT: prevent LateInitializationError
  @override
  Future<void> getOrderById(String orderId) async {
    getByIdCalls++;
    // optionally set selectedOrder so page has data
    // state = state.copyWith(selectedOrder: makeOrder(id: orderId));
  }
}

/// Helper: create a real OrderEntity (no mocks => no null crashes)
OrderEntity makeOrder({
  required String id,
  double total = 120.0,
  OrderStatus status = OrderStatus.pending,
  PaymentStatus paymentStatus = PaymentStatus.unpaid,
}) {
  final items = [
    OrderItemEntity(
      productId: 'p1',
      name: 'Product 1',
      price: total,
      quantity: 1,
      lineTotal: total,
      image: null,
    ),
  ];

  return OrderEntity(
    id: id,
    userId: 'u1',
    items: items,
    subtotal: total,
    shippingFee: 0,
    total: total,
    status: status,
    paymentStatus: paymentStatus,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    shippingAddress: null,
    notes: null,
    driverId: null,
    driverName: null,
  );
}

Widget wrapWith(FakeOrderViewModel vm, Widget child) {
  return ProviderScope(
    overrides: [orderViewModelProvider.overrideWith(() => vm)],
    child: MaterialApp(home: child),
  );
}

Future<void> pumpPage(WidgetTester tester, FakeOrderViewModel vm) async {
  await tester.pumpWidget(wrapWith(vm, const MyOrdersPage()));
  await tester.pump(); // first frame
  await tester.pump(); // flush Future.microtask(loadMyOrders)
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loading -> shows CartSkeleton', (tester) async {
    final vm = FakeOrderViewModel(const OrderState(isLoading: true));

    await pumpPage(tester, vm);

    expect(find.byType(CartSkeleton), findsOneWidget);
    expect(vm.loadCalls, 1);
  });

  testWidgets('error -> shows errorMessage', (tester) async {
    final vm = FakeOrderViewModel(
      const OrderState(errorMessage: 'Failed to load orders'),
    );

    await pumpPage(tester, vm);

    expect(find.text('Failed to load orders'), findsOneWidget);
    expect(vm.loadCalls, 1);
  });

  testWidgets('empty -> shows "No orders yet"', (tester) async {
    final vm = FakeOrderViewModel(const OrderState(orders: []));

    await pumpPage(tester, vm);

    expect(find.text('No orders yet'), findsOneWidget);
    expect(vm.loadCalls, 1);
  });

  testWidgets('success -> renders OrderCard list', (tester) async {
    final o1 = makeOrder(id: '1', total: 100);
    final o2 = makeOrder(id: '2', total: 200);

    final vm = FakeOrderViewModel(OrderState(orders: [o1, o2]));

    await pumpPage(tester, vm);

    expect(find.byType(OrderCard), findsNWidgets(2));
    expect(vm.loadCalls, 1);
  });

  testWidgets('tap OrderCard -> navigates to OrderDetailPage', (tester) async {
    final o1 = makeOrder(id: '99', total: 999);
    final vm = FakeOrderViewModel(OrderState(orders: [o1]));

    await pumpPage(tester, vm);

    await tester.tap(find.byType(OrderCard).first);

    // bounded settle (safer than unlimited)
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(OrderDetailPage), findsOneWidget);
    expect(vm.getByIdCalls, 1); // proves initState fired in OrderDetailPage
  });

  testWidgets('pull-to-refresh -> calls loadMyOrders again', (tester) async {
    final vm = FakeOrderViewModel(const OrderState(orders: []));

    await pumpPage(tester, vm);
    expect(vm.loadCalls, 1);

    // pull to refresh
    await tester.drag(find.byType(Scrollable), const Offset(0, 300));
    await tester.pump(); // start refresh
    await tester.pump(const Duration(seconds: 1));

    expect(vm.loadCalls, greaterThanOrEqualTo(2));
  });
}
