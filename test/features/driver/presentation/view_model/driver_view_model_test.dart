import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/driver/domain/entities/driver_order_stats.dart';
import 'package:click_shop/features/driver/domain/usecases/get_driver_order_stats_usecase.dart';
import 'package:click_shop/features/driver/domain/usecases/get_my_assiged_orders_usecase.dart';
import 'package:click_shop/features/driver/domain/usecases/update_ordeR_status._useccase.dart';
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyAssignedOrdersUsecase extends Mock
    implements GetMyAssignedOrdersUsecase {}

class MockUpdateOrderStatusUsecase extends Mock
    implements UpdateOrderStatusUsecase {}

class MockGetDriverOrderStatsUsecase extends Mock
    implements GetDriverOrderStatsUsecase {}

void main() {
  OrderEntity order({String id = 'o1'}) {
    return OrderEntity(
      id: id,
      userId: 'u1',
      items: const [
        OrderItemEntity(
          productId: 'p1',
          name: 'Item',
          price: 10,
          quantity: 1,
          lineTotal: 10,
          image: null,
        ),
      ],
      subtotal: 10,
      shippingFee: 2,
      total: 12,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.unpaid,
      shippingAddress: null,
      notes: null,
      driverId: 'd1',
      driverName: 'Driver',
      createdAt: null,
      updatedAt: null,
    );
  }

  ProviderContainer makeContainer({
    required MockGetMyAssignedOrdersUsecase getMy,
    required MockUpdateOrderStatusUsecase update,
    required MockGetDriverOrderStatsUsecase stats,
  }) {
    return ProviderContainer(
      overrides: [
        getMyAssignedOrdersUsecaseProvider.overrideWithValue(getMy),
        updateOrderStatusUsecaseProvider.overrideWithValue(update),
        getDriverOrderStatsUsecaseProvider.overrideWithValue(stats),
      ],
    );
  }

  group('DriverViewModel', () {
    test(
      'loadDashboard orders fail -> sets error (even if stats ok)',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(() => mockGetMy()).thenAnswer(
          (_) async =>
              Left(ApiFailure(message: 'orders fail', statusCode: 500)),
        );
        when(() => mockStats()).thenAnswer(
          (_) async => const Right(
            DriverOrderStats(totalAssigned: 1, totalDelivered: 1),
          ),
        );

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);

        await vm.loadDashboard();

        final st = container.read(driverViewModelProvider);

        // must keep the error from orders
        expect(st.errorMessage, 'orders fail');
        expect(st.status, DriverStatus.error);

        verify(() => mockGetMy()).called(1);
        verify(() => mockStats()).called(1);
      },
    );
    test('loadMyOrders failure -> sets error status + errorMessage', () async {
      final mockGetMy = MockGetMyAssignedOrdersUsecase();
      final mockUpdate = MockUpdateOrderStatusUsecase();
      final mockStats = MockGetDriverOrderStatsUsecase();

      when(() => mockGetMy()).thenAnswer(
        (_) async => Left(ApiFailure(message: 'fail', statusCode: 500)),
      );

      final container = makeContainer(
        getMy: mockGetMy,
        update: mockUpdate,
        stats: mockStats,
      );
      addTearDown(container.dispose);

      final vm = container.read(driverViewModelProvider.notifier);

      await vm.loadMyOrders();

      final st = container.read(driverViewModelProvider);
      expect(st.status, DriverStatus.error);
      expect(st.errorMessage, 'fail');

      verify(() => mockGetMy()).called(1);
    });

    test(
      'loadDashboard success -> loads orders + stats + sets loaded',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(
          () => mockGetMy(),
        ).thenAnswer((_) async => Right(<OrderEntity>[order(id: 'o1')]));
        when(() => mockStats()).thenAnswer(
          (_) async => const Right(
            DriverOrderStats(totalAssigned: 5, totalDelivered: 2),
          ),
        );

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);

        await vm.loadDashboard();

        final st = container.read(driverViewModelProvider);
        expect(st.status, DriverStatus.loaded);
        expect(st.orders.length, 1);
        expect(st.stats?.totalAssigned, 5);
        expect(st.errorMessage, isNull);

        verify(() => mockGetMy()).called(1);
        verify(() => mockStats()).called(1);
      },
    );

    test(
      'loadDashboard orders fail -> sets error (even if stats ok)',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(() => mockGetMy()).thenAnswer(
          (_) async =>
              Left(ApiFailure(message: 'orders fail', statusCode: 500)),
        );
        when(() => mockStats()).thenAnswer(
          (_) async => const Right(
            DriverOrderStats(totalAssigned: 1, totalDelivered: 1),
          ),
        );

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);

        await vm.loadDashboard();

        final st = container.read(driverViewModelProvider);
        expect(st.status, DriverStatus.error);
        expect(st.errorMessage, 'orders fail');

        verify(() => mockGetMy()).called(1);
        verify(() => mockStats()).called(1);
      },
    );

    test(
      'loadDashboard stats fail -> sets error (even if orders ok)',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(
          () => mockGetMy(),
        ).thenAnswer((_) async => Right(<OrderEntity>[order(id: 'o1')]));
        when(() => mockStats()).thenAnswer(
          (_) async => Left(ApiFailure(message: 'stats fail', statusCode: 500)),
        );

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);

        await vm.loadDashboard();

        final st = container.read(driverViewModelProvider);
        expect(st.status, DriverStatus.error);
        expect(st.errorMessage, 'stats fail');

        verify(() => mockGetMy()).called(1);
        verify(() => mockStats()).called(1);
      },
    );

    test(
      'updateOrderStatus success refreshAfter=false -> calls update only, no reload',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(
          () => mockUpdate(
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => const Right(true));

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);

        // seed some orders
        vm.state = vm.state.copyWith(
          status: DriverStatus.loaded,
          orders: <OrderEntity>[order(id: 'o1')],
        );

        await vm.updateOrderStatus(
          orderId: 'o1',
          status: 'delivered',
          refreshAfter: false,
        );

        final st = container.read(driverViewModelProvider);
        expect(st.status, DriverStatus.loaded);
        expect(st.errorMessage, isNull);

        verify(
          () => mockUpdate(
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ),
        ).called(1);
        verifyNever(() => mockGetMy());
      },
    );

    test(
      'updateOrderStatus success refreshAfter=true -> calls update then reloads orders',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(
          () => mockUpdate(
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async => const Right(true));

        when(
          () => mockGetMy(),
        ).thenAnswer((_) async => Right(<OrderEntity>[order(id: 'o1')]));

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);
        vm.state = vm.state.copyWith(
          status: DriverStatus.loaded,
          orders: <OrderEntity>[order(id: 'o1')],
        );

        await vm.updateOrderStatus(
          orderId: 'o1',
          status: 'delivered',
          refreshAfter: true,
        );

        final st = container.read(driverViewModelProvider);
        expect(st.status, DriverStatus.loaded);
        expect(st.orders.length, 1);
        expect(st.errorMessage, isNull);

        verify(
          () => mockUpdate(
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ),
        ).called(1);
        verify(() => mockGetMy()).called(1);
      },
    );

    test(
      'updateOrderStatus failure -> sets error status and message',
      () async {
        final mockGetMy = MockGetMyAssignedOrdersUsecase();
        final mockUpdate = MockUpdateOrderStatusUsecase();
        final mockStats = MockGetDriverOrderStatsUsecase();

        when(
          () => mockUpdate(
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ),
        ).thenAnswer(
          (_) async =>
              Left(ApiFailure(message: 'update fail', statusCode: 400)),
        );

        final container = makeContainer(
          getMy: mockGetMy,
          update: mockUpdate,
          stats: mockStats,
        );
        addTearDown(container.dispose);

        final vm = container.read(driverViewModelProvider.notifier);

        await vm.updateOrderStatus(
          orderId: 'o1',
          status: 'delivered',
          refreshAfter: false,
        );

        final st = container.read(driverViewModelProvider);
        expect(st.status, DriverStatus.error);
        expect(st.errorMessage, 'update fail');

        verify(
          () => mockUpdate(
            orderId: any(named: 'orderId'),
            status: any(named: 'status'),
          ),
        ).called(1);
      },
    );

    test('clearError -> sets errorMessage null', () {
      final mockGetMy = MockGetMyAssignedOrdersUsecase();
      final mockUpdate = MockUpdateOrderStatusUsecase();
      final mockStats = MockGetDriverOrderStatsUsecase();

      final container = makeContainer(
        getMy: mockGetMy,
        update: mockUpdate,
        stats: mockStats,
      );
      addTearDown(container.dispose);

      final vm = container.read(driverViewModelProvider.notifier);
      vm.state = vm.state.copyWith(
        status: DriverStatus.error,
        errorMessage: 'some error',
      );

      vm.clearError();

      final st = container.read(driverViewModelProvider);
      expect(st.errorMessage, isNull);
    });
  });
}
