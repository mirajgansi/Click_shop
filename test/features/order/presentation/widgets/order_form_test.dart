import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/order/presentation/state/order_state.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';
import 'package:click_shop/features/order/presentation/widgets/order_form.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class TestOrderViewModel extends Notifier<OrderState>
    implements OrderViewModel {
  TestOrderViewModel(this.testState, {this.onCreateOrder});

  final OrderState testState;
  final Future<void> Function(Map<String, dynamic> shipping)? onCreateOrder;

  @override
  OrderState build() => testState;

  @override
  Future<void> createOrderFromCart(Map<String, dynamic> shippingJson) async {
    if (onCreateOrder != null) {
      await onCreateOrder!(shippingJson);
    }
  }

  @override
  void clearActionSuccess() {
    state = state.copyWith(actionSuccess: false);
  }

  @override
  Future<void> cancelMyOrder(String orderId) {
    // TODO: implement cancelMyOrder
    throw UnimplementedError();
  }

  @override
  void clearError() {
    // TODO: implement clearError
  }

  @override
  Future<void> getMyOrders() {
    // TODO: implement getMyOrders
    throw UnimplementedError();
  }

  @override
  Future<void> getOrderById(String orderId) {
    // TODO: implement getOrderById
    throw UnimplementedError();
  }

  @override
  Future<void> loadCurrentUser() {
    // TODO: implement loadCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<void> loadMyOrders() {
    // TODO: implement loadMyOrders
    throw UnimplementedError();
  }
}

void main() {
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;

  setUp(() {
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
  });

  Widget createWidget({
    required OrderState orderState,
    Future<void> Function(Map<String, dynamic> shipping)? onCreateOrder,
    Map<String, dynamic>? initialShippingJson,
  }) {
    return ProviderScope(
      overrides: [
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        orderViewModelProvider.overrideWith(
          () => TestOrderViewModel(orderState, onCreateOrder: onCreateOrder),
        ),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showCheckoutSheet(
                        context: context,
                        ref: ref,
                        total: 500,
                        initialShippingJson: initialShippingJson,
                      );
                    },
                    child: const Text('Open'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders checkout sheet title and total', (tester) async {
    when(() => mockGetCurrentUserUsecase()).thenAnswer(
      (_) async => const Left(LocalDatabaseFailure(message: 'No cached user')),
    );

    await tester.pumpWidget(createWidget(orderState: const OrderState()));

    await openSheet(tester);

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Total Cost'), findsOneWidget);
    expect(find.text('Rs.500'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
  });

  testWidgets('prefills shipping form from current user', (tester) async {
    when(() => mockGetCurrentUserUsecase()).thenAnswer(
      (_) async => const Right(
        AuthEntity(
          userId: 'u1',
          username: 'Miraj',
          email: 'miraj@test.com',
          password: 'password123',
          phoneNumber: '9800000000',
          location: 'Kathmandu',
        ),
      ),
    );

    await tester.pumpWidget(createWidget(orderState: const OrderState()));

    await openSheet(tester);

    expect(find.text('Miraj'), findsOneWidget);
    expect(find.text('9800000000'), findsOneWidget);
    expect(find.text('Kathmandu'), findsOneWidget);
  });

  testWidgets('uses initial shipping json values', (tester) async {
    when(() => mockGetCurrentUserUsecase()).thenAnswer(
      (_) async => const Right(
        AuthEntity(
          userId: 'u1',
          username: 'Other User',
          email: 'other@test.com',
          password: 'password123',
          phoneNumber: '1111111111',
          location: 'Pokhara',
        ),
      ),
    );

    await tester.pumpWidget(
      createWidget(
        orderState: const OrderState(),
        initialShippingJson: {
          'userName': 'Initial Name',
          'phone': '9812345678',
          'address1': 'Initial Address',
          'address2': 'Near School',
          'city': 'Kathmandu',
          'zip': '44600',
        },
      ),
    );

    await openSheet(tester);

    expect(find.text('Initial Name'), findsOneWidget);
    expect(find.text('9812345678'), findsOneWidget);
    expect(find.text('Initial Address'), findsOneWidget);
    expect(find.text('Near School'), findsOneWidget);
    expect(find.text('Kathmandu'), findsOneWidget);
    expect(find.text('44600'), findsOneWidget);
  });

  testWidgets('closes sheet when close icon is tapped', (tester) async {
    when(() => mockGetCurrentUserUsecase()).thenAnswer(
      (_) async => const Left(LocalDatabaseFailure(message: 'No cached user')),
    );

    await tester.pumpWidget(createWidget(orderState: const OrderState()));

    await openSheet(tester);

    expect(find.text('Checkout'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsNothing);
  });
}
