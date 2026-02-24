import 'package:click_shop/features/driver/presentation/pages/bottom_screen/assigned_page.dart';
import 'package:click_shop/features/driver/presentation/pages/order_detail_page.dart'
    as driver_detail;
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/widgets/assigned_page_sekeleton.dart';
import 'package:click_shop/features/driver/presentation/widgets/driver_card_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeDriverViewModel extends DriverViewModel {
  FakeDriverViewModel(this._initial);

  final DriverState _initial;

  int loadCalls = 0;

  @override
  DriverState build() => _initial;

  @override
  Future<void> loadMyOrders() async {
    loadCalls++;
  }
}

/// helper: real OrderEntity
OrderEntity makeOrder({required String id, required OrderStatus status}) {
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
    paymentStatus: PaymentStatus.unpaid,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Widget wrap(FakeDriverViewModel vm) {
  return ProviderScope(
    overrides: [driverViewModelProvider.overrideWith(() => vm)],
    child: const MaterialApp(home: AssignedPage()),
  );
}

/// AssignedPage triggers microtask(loadMyOrders) in initState -> pump twice
Future<void> pumpAssigned(WidgetTester tester, FakeDriverViewModel vm) async {
  await tester.pumpWidget(wrap(vm));
  await tester.pump();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('error -> shows error message and Try again calls loadMyOrders', (
    tester,
  ) async {
    final vm = FakeDriverViewModel(
      const DriverState(
        status: DriverStatus.error,
        errorMessage: 'Network error',
      ),
    );

    await pumpAssigned(tester, vm);

    expect(find.text('Network error'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    // initState call + button call
    expect(vm.loadCalls, greaterThanOrEqualTo(2));
  });

  testWidgets('no shipped orders -> shows "No assigned orders yet"', (
    tester,
  ) async {
    final vm = FakeDriverViewModel(
      DriverState(
        status: DriverStatus.loaded,
        orders: [
          makeOrder(id: '1', status: OrderStatus.pending),
          makeOrder(id: '2', status: OrderStatus.paid),
          makeOrder(id: '3', status: OrderStatus.delivered),
        ],
      ),
    );

    await pumpAssigned(tester, vm);

    expect(find.text('No assigned orders yet'), findsOneWidget);
  });

  testWidgets('shipped orders -> shows DriverOrderCard list', (tester) async {
    final vm = FakeDriverViewModel(
      DriverState(
        status: DriverStatus.loaded,
        orders: [
          makeOrder(id: '1', status: OrderStatus.shipped),
          makeOrder(id: '2', status: OrderStatus.shipped),
          makeOrder(id: '3', status: OrderStatus.pending),
        ],
      ),
    );

    await pumpAssigned(tester, vm);

    // only shipped orders appear
    expect(find.byType(DriverOrderCard), findsNWidgets(2));
  });

  testWidgets('tap DriverOrderCard -> navigates to DriverOrderDetailPage', (
    tester,
  ) async {
    final vm = FakeDriverViewModel(
      DriverState(
        status: DriverStatus.loaded,
        orders: [makeOrder(id: 'X1', status: OrderStatus.shipped)],
      ),
    );

    await pumpAssigned(tester, vm);

    expect(find.byType(DriverOrderCard), findsOneWidget);

    await tester.tap(find.byType(DriverOrderCard).first);
    await tester.pumpAndSettle();

    // DriverOrderDetailPage is in driver order detail file
    expect(find.byType(driver_detail.DriverOrderDetailPage), findsOneWidget);
  });

  testWidgets('pull-to-refresh -> calls loadMyOrders again', (tester) async {
    final vm = FakeDriverViewModel(
      const DriverState(status: DriverStatus.loaded, orders: []),
    );

    await pumpAssigned(tester, vm);
    expect(vm.loadCalls, 1);

    await tester.drag(find.byType(Scrollable), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(vm.loadCalls, greaterThanOrEqualTo(2));
  });
}
