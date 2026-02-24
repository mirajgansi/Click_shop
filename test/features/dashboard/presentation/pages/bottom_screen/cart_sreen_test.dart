import 'package:click_shop/features/cart/presentation/state/cart_state.dart';
import 'package:click_shop/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:click_shop/features/cart/presentation/widgets/checkout_button_widget.dart';
import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/cart_sreen.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/cart_sekeleton_widget.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockProductEntity extends Mock implements ProductEntity {}

/// ✅ Must EXTEND CartViewModel (because provider is NotifierProvider<CartViewModel, CartState>)
class FakeCartViewModel extends CartViewModel {
  FakeCartViewModel(this._initial);

  final CartState _initial;

  int getCartCalls = 0;
  int deleteCalls = 0;
  int changeQtyCalls = 0;

  String? lastDeletedId;
  ({String itemId, int newQty})? lastQtyChange;

  @override
  CartState build() => _initial;

  @override
  Future<void> getCart() async {
    getCartCalls++;
  }

  @override
  Future<bool> deleteFromCart(String productId) async {
    deleteCalls++;
    lastDeletedId = productId;
    return true;
  }

  @override
  Future<void> changeQty({required String itemId, required int newQty}) async {
    changeQtyCalls++;
    lastQtyChange = (itemId: itemId, newQty: newQty);
  }
}

/// Wrap widget with provider override
Widget wrap(FakeCartViewModel vm) {
  return ProviderScope(
    overrides: [cartViewModelProvider.overrideWith(() => vm)],
    child: const MaterialApp(home: CartScreen()),
  );
}

/// CartScreen calls getCart() in initState via microtask -> pump twice
Future<void> pumpCart(WidgetTester tester, FakeCartViewModel vm) async {
  await tester.pumpWidget(wrap(vm));
  await tester.pump();
  await tester.pump();
}

/// ✅ helper to make a ProductEntity mock that won’t crash UI
MockProductEntity makeProduct({
  required String id,
  required String name,
  required num price,
  required int inStock,
  required int qty,
  String image = '',
}) {
  final p = MockProductEntity();

  when(() => p.id).thenReturn(id);
  when(() => p.name).thenReturn(name);
  when(() => p.price).thenReturn(price.toDouble());
  when(() => p.inStock).thenReturn(inStock);
  when(() => p.quantity).thenReturn(qty);
  when(() => p.image).thenReturn(image);

  // CartViewModel.changeQty() uses item.copyWith(quantity: newQty)
  when(() => p.copyWith(quantity: any(named: 'quantity'))).thenAnswer((inv) {
    final newQ = inv.namedArguments[#quantity] as int?;
    return makeProduct(
      id: id,
      name: name,
      price: price,
      inStock: inStock,
      qty: newQ ?? qty,
      image: image,
    );
  });

  return p;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('error -> shows error text', (tester) async {
    final vm = FakeCartViewModel(
      CartState.initial().copyWith(error: 'Failed to load', isLoading: false),
    );

    await pumpCart(tester, vm);

    expect(find.text('Failed to load'), findsOneWidget);
    expect(vm.getCartCalls, 1);
  });

  testWidgets('empty -> shows "Your cart is empty"', (tester) async {
    final vm = FakeCartViewModel(
      CartState.initial().copyWith(cartProducts: const [], isLoading: false),
    );

    await pumpCart(tester, vm);

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byType(CheckoutButton), findsNothing);
    expect(vm.getCartCalls, 1);
  });

  testWidgets('non-empty -> shows list and CheckoutButton', (tester) async {
    final p1 = makeProduct(
      id: '1',
      name: 'Apple',
      price: 100,
      inStock: 5,
      qty: 2,
      image: '',
    );

    final vm = FakeCartViewModel(
      CartState.initial().copyWith(cartProducts: [p1], isLoading: false),
    );

    await pumpCart(tester, vm);

    expect(find.text('Apple'), findsOneWidget);
    expect(find.byType(CheckoutButton), findsOneWidget);
  });

  testWidgets('tap remove (X) -> calls deleteFromCart', (tester) async {
    final p1 = makeProduct(
      id: '1',
      name: 'Apple',
      price: 100,
      inStock: 5,
      qty: 1,
    );

    final vm = FakeCartViewModel(
      CartState.initial().copyWith(cartProducts: [p1], isLoading: false),
    );

    await pumpCart(tester, vm);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();

    expect(vm.deleteCalls, 1);
    expect(vm.lastDeletedId, '1');
  });

  testWidgets('tap plus -> calls changeQty with qty+1', (tester) async {
    final p1 = makeProduct(
      id: '1',
      name: 'Apple',
      price: 100,
      inStock: 5,
      qty: 2,
    );

    final vm = FakeCartViewModel(
      CartState.initial().copyWith(cartProducts: [p1], isLoading: false),
    );

    await pumpCart(tester, vm);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();

    expect(vm.changeQtyCalls, 1);
    expect(vm.lastQtyChange?.itemId, '1');
    expect(vm.lastQtyChange?.newQty, 3);
  });

  testWidgets('tap minus when qty==1 -> does not call changeQty', (
    tester,
  ) async {
    final p1 = makeProduct(
      id: '1',
      name: 'Apple',
      price: 100,
      inStock: 5,
      qty: 1,
    );

    final vm = FakeCartViewModel(
      CartState.initial().copyWith(cartProducts: [p1], isLoading: false),
    );

    await pumpCart(tester, vm);

    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pump();

    expect(vm.changeQtyCalls, 0);
  });

  testWidgets('pull-to-refresh -> calls getCart again', (tester) async {
    final vm = FakeCartViewModel(
      CartState.initial().copyWith(cartProducts: const [], isLoading: false),
    );

    await pumpCart(tester, vm);
    expect(vm.getCartCalls, 1);

    await tester.drag(find.byType(Scrollable), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(vm.getCartCalls, greaterThanOrEqualTo(2));
  });
}
