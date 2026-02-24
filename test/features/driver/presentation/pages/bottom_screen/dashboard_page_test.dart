import 'package:click_shop/features/driver/presentation/pages/bottom_screen/dashboard_page.dart';
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/widgets/dashboard_sekeleton.dart';
import 'package:click_shop/features/driver/presentation/widgets/stats_card_widget.dart';
import 'package:click_shop/features/driver/domain/entities/driver_order_stats.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';

import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/core/error/failures.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// --------------------
/// Fake Driver VM
/// --------------------
class FakeDriverViewModel extends DriverViewModel {
  FakeDriverViewModel(this._initial);

  final DriverState _initial;

  int loadDashboardCalls = 0;

  @override
  DriverState build() => _initial;

  @override
  Future<void> loadDashboard() async {
    loadDashboardCalls++;
  }
}

/// --------------------
/// Fake GetCurrentUserUsecase
/// --------------------
class FakeGetCurrentUserUsecase implements GetCurrentUserUsecase {
  FakeGetCurrentUserUsecase(this._result);

  final Either<Failure, AuthEntity> _result;

  @override
  Future<Either<Failure, AuthEntity>> call() async => _result;
}

/// --------------------
/// Helpers
/// --------------------
OrderEntity makeOrder({
  required String id,
  required OrderStatus status,
  required DateTime updatedAt,
  double total = 100,
}) {
  return OrderEntity(
    id: id,
    userId: 'u1',
    items: const [
      OrderItemEntity(
        productId: 'p1',
        name: 'Item',
        price: 100,
        quantity: 1,
        lineTotal: 100,
      ),
    ],
    subtotal: total,
    shippingFee: 0,
    total: total,
    status: status,
    paymentStatus: PaymentStatus.unpaid,
    createdAt: updatedAt,
    updatedAt: updatedAt,
  );
}

Widget wrap({
  required FakeDriverViewModel vm,
  required GetCurrentUserUsecase userUsecase,
}) {
  return ProviderScope(
    overrides: [
      driverViewModelProvider.overrideWith(() => vm),
      getCurrentUserUsecaseProvider.overrideWithValue(userUsecase),
    ],
    child: const MaterialApp(home: DriverDashboardPage()),
  );
}

Future<void> pumpDash(
  WidgetTester tester, {
  required FakeDriverViewModel vm,
  required GetCurrentUserUsecase userUsecase,
}) async {
  await tester.pumpWidget(wrap(vm: vm, userUsecase: userUsecase));
  await tester.pump(); // first frame
  await tester.pump(); // flush initState microtask(loadDashboard)
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loading -> shows DriverDashboardSkeleton', (tester) async {
    final vm = FakeDriverViewModel(
      const DriverState(status: DriverStatus.loading),
    );

    final userUsecase = FakeGetCurrentUserUsecase(
      right(const AuthEntity(username: 'Miraj', email: 'm@test.com')),
    );

    await pumpDash(tester, vm: vm, userUsecase: userUsecase);

    expect(find.byType(DriverDashboardSkeleton), findsOneWidget);
    expect(vm.loadDashboardCalls, 1);
  });

  testWidgets('error -> shows error and Try again calls loadDashboard', (
    tester,
  ) async {
    final vm = FakeDriverViewModel(
      const DriverState(
        status: DriverStatus.error,
        errorMessage: 'Network error',
      ),
    );

    final userUsecase = FakeGetCurrentUserUsecase(
      right(const AuthEntity(username: 'Miraj', email: 'm@test.com')),
    );

    await pumpDash(tester, vm: vm, userUsecase: userUsecase);

    expect(find.text('Network error'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    // initState + retry
    expect(vm.loadDashboardCalls, greaterThanOrEqualTo(2));
  });

  testWidgets('success + empty orders -> shows stats and "No activity yet"', (
    tester,
  ) async {
    final vm = FakeDriverViewModel(
      const DriverState(
        status: DriverStatus.loaded,
        orders: [],
        stats: DriverOrderStats(totalAssigned: 3, totalDelivered: 1),
      ),
    );

    final userUsecase = FakeGetCurrentUserUsecase(
      right(const AuthEntity(username: 'Miraj', email: 'm@test.com')),
    );

    await pumpDash(tester, vm: vm, userUsecase: userUsecase);

    expect(find.textContaining('Good'), findsOneWidget); // greeting
    expect(find.byType(StatCard), findsNWidgets(2));

    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('No activity yet'), findsOneWidget);
  });

  testWidgets('success + orders -> shows recent activity cards', (
    tester,
  ) async {
    final now = DateTime(2026, 2, 24, 12, 0);

    final vm = FakeDriverViewModel(
      DriverState(
        status: DriverStatus.loaded,
        stats: const DriverOrderStats(totalAssigned: 5, totalDelivered: 2),
        orders: [
          makeOrder(
            id: 'AAAAAA111',
            status: OrderStatus.delivered,
            updatedAt: now.subtract(const Duration(minutes: 5)),
            total: 300,
          ),
          makeOrder(
            id: 'BBBBBB222',
            status: OrderStatus.shipped,
            updatedAt: now.subtract(const Duration(hours: 1)),
            total: 200,
          ),
        ],
      ),
    );

    final userUsecase = FakeGetCurrentUserUsecase(
      right(const AuthEntity(username: 'Miraj', email: 'm@test.com')),
    );

    await tester.pumpWidget(wrap(vm: vm, userUsecase: userUsecase));
    await tester.pump();
    await tester.pump();

    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.textContaining('Delivered Order #'), findsOneWidget);
    expect(find.textContaining('Assigned Order #'), findsOneWidget);
    expect(find.textContaining('Total: Rs'), findsWidgets);
  });
}
