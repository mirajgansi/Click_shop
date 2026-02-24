import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:click_shop/features/order/domain/usecases/cancel_my_order_usecase.dart';
import 'package:click_shop/features/order/domain/usecases/create_order_from_cart_usecase.dart';
import 'package:click_shop/features/order/domain/usecases/get_my_order_usecase.dart';
import 'package:click_shop/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateOrderFromCartUsecase extends Mock
    implements CreateOrderFromCartUsecase {}

class MockGetMyOrdersUsecase extends Mock implements GetMyOrdersUsecase {}

class MockGetOrderByIdUsecase extends Mock implements GetOrderByIdUsecase {}

class MockCancelMyOrderUsecase extends Mock implements CancelMyOrderUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class FakeCreateOrderParams extends Fake implements CreateOrderParams {}

class FakeGetOrderByIdParams extends Fake implements GetOrderByIdParams {}

class FakeCancelOrderParams extends Fake implements CancelOrderParams {}

ProviderContainer makeOrderContainer({
  required MockCreateOrderFromCartUsecase create,
  required MockGetMyOrdersUsecase getMy,
  required MockGetOrderByIdUsecase getById,
  required MockCancelMyOrderUsecase cancel,
  required MockGetCurrentUserUsecase currentUser,
}) {
  return ProviderContainer(
    overrides: [
      createOrderFromCartUsecaseProvider.overrideWithValue(create),
      getMyOrdersUsecaseProvider.overrideWithValue(getMy),
      getOrderByIdUsecaseProvider.overrideWithValue(getById),
      cancelMyOrderUsecaseProvider.overrideWithValue(cancel),
      getCurrentUserUsecaseProvider.overrideWithValue(currentUser),
    ],
  );
}

OrderEntity order({String id = 'o1', int qty = 1}) {
  return OrderEntity(
    id: id,
    userId: 'u1',
    items: [
      OrderItemEntity(
        productId: 'p1',
        name: 'Item',
        price: 10,
        quantity: qty,
        lineTotal: 10 * qty.toDouble(),
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
    driverId: null,
    driverName: null,
    createdAt: null,
    updatedAt: null,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateOrderParams());
    registerFallbackValue(FakeGetOrderByIdParams());
    registerFallbackValue(FakeCancelOrderParams());
  });

  test('createOrderFromCart success -> actionSuccess true', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(
      () => mockCreate(any<CreateOrderParams>()),
    ).thenAnswer((_) async => const Right(true));

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.createOrderFromCart({'address': 'ktm'});

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.actionSuccess, isTrue);
    expect(st.errorMessage, isNull);

    verify(() => mockCreate(any<CreateOrderParams>())).called(1);
  });

  test('createOrderFromCart failure -> sets errorMessage', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(() => mockCreate(any<CreateOrderParams>())).thenAnswer(
      (_) async => Left(ApiFailure(message: 'create fail', statusCode: 400)),
    );

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.createOrderFromCart({'address': 'ktm'});

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.actionSuccess, isFalse);
    expect(st.errorMessage, 'create fail');

    verify(() => mockCreate(any<CreateOrderParams>())).called(1);
  });
  test('createOrderFromCart success -> actionSuccess true', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(
      () => mockCreate(any<CreateOrderParams>()),
    ).thenAnswer((_) async => const Right(true));

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.createOrderFromCart({'address': 'ktm'});

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.actionSuccess, isTrue);
    expect(st.errorMessage, isNull);

    verify(() => mockCreate(any<CreateOrderParams>())).called(1);
  });

  test('createOrderFromCart failure -> sets errorMessage', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(() => mockCreate(any<CreateOrderParams>())).thenAnswer(
      (_) async => Left(ApiFailure(message: 'create fail', statusCode: 400)),
    );

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.createOrderFromCart({'address': 'ktm'});

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.actionSuccess, isFalse);
    expect(st.errorMessage, 'create fail');

    verify(() => mockCreate(any<CreateOrderParams>())).called(1);
  });
  test('getMyOrders success -> sets orders', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(
      () => mockGetMy(),
    ).thenAnswer((_) async => Right(<OrderEntity>[order(id: 'o1')]));

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.getMyOrders();

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.orders.length, 1);
    expect(st.errorMessage, isNull);

    verify(() => mockGetMy()).called(1);
  });

  test('getMyOrders failure -> sets errorMessage', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(() => mockGetMy()).thenAnswer(
      (_) async => Left(ApiFailure(message: 'load fail', statusCode: 500)),
    );

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.getMyOrders();

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.errorMessage, 'load fail');

    verify(() => mockGetMy()).called(1);
  });
  test('getMyOrders success -> sets orders', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(
      () => mockGetMy(),
    ).thenAnswer((_) async => Right(<OrderEntity>[order(id: 'o1')]));

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.getMyOrders();

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.orders.length, 1);
    expect(st.errorMessage, isNull);

    verify(() => mockGetMy()).called(1);
  });

  test('getMyOrders failure -> sets errorMessage', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(() => mockGetMy()).thenAnswer(
      (_) async => Left(ApiFailure(message: 'load fail', statusCode: 500)),
    );

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.getMyOrders();

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.errorMessage, 'load fail');

    verify(() => mockGetMy()).called(1);
  });
  test('getOrderById success -> sets selectedOrder', () async {
    final mockCreate = MockCreateOrderFromCartUsecase();
    final mockGetMy = MockGetMyOrdersUsecase();
    final mockGetById = MockGetOrderByIdUsecase();
    final mockCancel = MockCancelMyOrderUsecase();
    final mockCurrent = MockGetCurrentUserUsecase();

    when(
      () => mockGetById(any<GetOrderByIdParams>()),
    ).thenAnswer((_) async => Right(order(id: 'o99')));

    final container = makeOrderContainer(
      create: mockCreate,
      getMy: mockGetMy,
      getById: mockGetById,
      cancel: mockCancel,
      currentUser: mockCurrent,
    );
    addTearDown(container.dispose);

    final vm = container.read(orderViewModelProvider.notifier);

    await vm.getOrderById('o99');

    final st = container.read(orderViewModelProvider);
    expect(st.isLoading, isFalse);
    expect(st.selectedOrder?.id, 'o99');
    expect(st.errorMessage, isNull);

    verify(() => mockGetById(any<GetOrderByIdParams>())).called(1);
  });
  test(
    'cancelMyOrder success -> actionSuccess true and refreshes orders',
    () async {
      final mockCreate = MockCreateOrderFromCartUsecase();
      final mockGetMy = MockGetMyOrdersUsecase();
      final mockGetById = MockGetOrderByIdUsecase();
      final mockCancel = MockCancelMyOrderUsecase();
      final mockCurrent = MockGetCurrentUserUsecase();

      when(
        () => mockCancel(any<CancelOrderParams>()),
      ).thenAnswer((_) async => const Right(true));

      when(
        () => mockGetMy(),
      ).thenAnswer((_) async => Right(<OrderEntity>[order(id: 'o1')]));

      final container = makeOrderContainer(
        create: mockCreate,
        getMy: mockGetMy,
        getById: mockGetById,
        cancel: mockCancel,
        currentUser: mockCurrent,
      );
      addTearDown(container.dispose);

      final vm = container.read(orderViewModelProvider.notifier);

      await vm.cancelMyOrder('o1');

      // IMPORTANT: because fold callback is async, wait a microtask so refresh finishes
      await Future<void>.delayed(Duration.zero);

      final st = container.read(orderViewModelProvider);
      expect(st.actionSuccess, isTrue);
      expect(st.orders.length, 1);
      expect(st.errorMessage, isNull);

      verify(() => mockCancel(any<CancelOrderParams>())).called(1);
      verify(() => mockGetMy()).called(1); // refresh
    },
  );
  test(
    'cancelMyOrder failure -> sets errorMessage and does not refresh',
    () async {
      final mockCreate = MockCreateOrderFromCartUsecase();
      final mockGetMy = MockGetMyOrdersUsecase();
      final mockGetById = MockGetOrderByIdUsecase();
      final mockCancel = MockCancelMyOrderUsecase();
      final mockCurrent = MockGetCurrentUserUsecase();

      when(() => mockCancel(any<CancelOrderParams>())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'cancel fail', statusCode: 400)),
      );

      final container = makeOrderContainer(
        create: mockCreate,
        getMy: mockGetMy,
        getById: mockGetById,
        cancel: mockCancel,
        currentUser: mockCurrent,
      );
      addTearDown(container.dispose);

      final vm = container.read(orderViewModelProvider.notifier);

      await vm.cancelMyOrder('o1');

      final st = container.read(orderViewModelProvider);
      expect(st.actionSuccess, isFalse);
      expect(st.errorMessage, 'cancel fail');

      verify(() => mockCancel(any<CancelOrderParams>())).called(1);
      verifyNever(() => mockGetMy());
    },
  );
}
