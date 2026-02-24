import 'package:click_shop/features/driver/presentation/pages/order_detail_page.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:click_shop/features/driver/domain/entities/shipping_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeDriverViewModel extends DriverViewModel {
  FakeDriverViewModel(this._initial);
  final _initial;

  @override
  build() => _initial;

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    bool refreshAfter = true,
  }) async {}
}

OrderEntity makeOrder({required OrderStatus status}) {
  return OrderEntity(
    id: 'O1',
    userId: 'U1',
    items: const [
      OrderItemEntity(
        productId: 'p1',
        name: 'Item 1',
        price: 100,
        quantity: 2,
        lineTotal: 200,
      ),
      // add another item to make list longer (helps scrolling realism)
      OrderItemEntity(
        productId: 'p2',
        name: 'Item 2',
        price: 50,
        quantity: 1,
        lineTotal: 50,
      ),
    ],
    subtotal: 250,
    shippingFee: 20,
    total: 270,
    status: status,
    paymentStatus: PaymentStatus.unpaid,
    shippingAddress: const ShippingAddressEntity(
      userName: 'Ram',
      phone: '9800000000',
      address1: 'Street 1',
      city: 'Kathmandu',
      zip: '44600',
    ),
    notes: 'Leave at door',
    createdAt: DateTime(2026, 1, 1, 10, 30),
    updatedAt: DateTime(2026, 1, 1, 11, 0),
  );
}

Widget wrap(FakeDriverViewModel vm, OrderEntity order) {
  return ProviderScope(
    overrides: [driverViewModelProvider.overrideWith(() => vm)],
    child: MaterialApp(home: DriverOrderDetailPage(order: order)),
  );
}

Future<void> pumpPage(WidgetTester tester, Widget w) async {
  await tester.pumpWidget(w);
  await tester.pump();
  await tester.pump();
}

Future<void> scrollDown(WidgetTester tester, {double dy = 600}) async {
  // Your page body is a ListView, target it directly
  final list = find.byType(ListView);
  expect(list, findsOneWidget);

  await tester.drag(list, Offset(0, -dy));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders Notes section (scroll if needed)', (tester) async {
    final vm = FakeDriverViewModel(const Object());
    final order = makeOrder(status: OrderStatus.shipped);

    await pumpPage(tester, wrap(vm, order));

    // Notes is near bottom, so scroll a couple times
    for (int i = 0; i < 3; i++) {
      if (find.text('Notes').evaluate().isNotEmpty) break;
      await scrollDown(tester, dy: 700);
    }

    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('shipped -> shows Mark as Delivered button (scroll if needed)', (
    tester,
  ) async {
    final vm = FakeDriverViewModel(const Object());
    final order = makeOrder(status: OrderStatus.shipped);

    await pumpPage(tester, wrap(vm, order));

    for (int i = 0; i < 4; i++) {
      if (find.text('Mark as Delivered').evaluate().isNotEmpty) break;
      await scrollDown(tester, dy: 700);
    }

    expect(find.text('Mark as Delivered'), findsOneWidget);
  });

  testWidgets('not shipped -> does NOT show Mark as Delivered', (tester) async {
    final vm = FakeDriverViewModel(const Object());
    final order = makeOrder(status: OrderStatus.delivered);

    await pumpPage(tester, wrap(vm, order));

    // scroll through the page to be sure
    for (int i = 0; i < 4; i++) {
      await scrollDown(tester, dy: 700);
    }

    expect(find.text('Mark as Delivered'), findsNothing);
  });
}
