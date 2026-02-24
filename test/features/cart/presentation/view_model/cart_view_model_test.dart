import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/cart/domain/entities/cart_entity.dart';
import 'package:click_shop/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/clear_cart_prodcut_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/delete_cart_product_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/get_cart_products_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:click_shop/features/cart/presentation/state/cart_state.dart';
import 'package:click_shop/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCartProductsUsecase extends Mock
    implements GetCartProductsUsecase {}

class MockAddToCartUsecase extends Mock implements AddToCartUsecase {}

class MockDeleteCartItemUsecase extends Mock implements DeleteCartItemUsecase {}

class MockClearCartUsecase extends Mock implements ClearCartUsecase {}

class MockUpdateCartQtyUsecase extends Mock implements UpdateCartQtyUsecase {}

class FakeAddToCartParams extends Fake implements AddToCartParams {}

class FakeDeleteCartItemParams extends Fake implements DeleteCartItemParams {}

class FakeUpdateCartQtyParams extends Fake implements UpdateCartQtyParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAddToCartParams());
    registerFallbackValue(FakeDeleteCartItemParams());
    registerFallbackValue(FakeUpdateCartQtyParams());
  });
  ProductEntity cartProduct({
    required String id,
    required double price,
    int quantity = 1,
  }) {
    return ProductEntity(
      id: id,
      price: price,
      quantity: quantity,
      name: 'Item$id',
      image: '',
      description: '',
      inStock: 12,
      category: '',
      nutritionalInfo: '',
      // fill required fields in your constructor
    );
  }

  ProviderContainer makeContainer({
    required MockGetCartProductsUsecase getCart,
    required MockAddToCartUsecase add,
    required MockDeleteCartItemUsecase del,
    required MockClearCartUsecase clear,
    required MockUpdateCartQtyUsecase updateQty,
  }) {
    return ProviderContainer(
      overrides: [
        getCartProductsUsecaseProvider.overrideWithValue(getCart),
        addToCartUsecaseProvider.overrideWithValue(add),
        deleteCartItemUsecaseProvider.overrideWithValue(del),
        clearCartUsecaseProvider.overrideWithValue(clear),
        updateCartQtyUsecaseProvider.overrideWithValue(updateQty),
      ],
    );
  }

  CartItemEntity item({
    required String cartItemId,
    required String productId,
    int quantity = 1,
  }) {
    return CartItemEntity(
      cartItemId: cartItemId,
      productId: productId,
      quantity: quantity,
    );
  }

  group('CartViewModel', () {
    test('getCart success -> sets cartProducts', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      container.read(cartViewModelProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      clearInteractions(mockGet);

      when(() => mockGet()).thenAnswer(
        (_) async => Right(<ProductEntity>[
          cartProduct(id: 'p1', price: 10, quantity: 1),
        ]),
      );

      final vm = container.read(cartViewModelProvider.notifier);
      await vm.getCart();

      final st = container.read(cartViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.cartProducts.length, 1);
      expect(st.error, isNull);

      verify(() => mockGet()).called(1);
    });
    test('getCart failure -> sets error and clears products', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      // init call + explicit call both will use this unless we clear
      when(() => mockGet()).thenAnswer(
        (_) async => Left(ApiFailure(message: 'fail', statusCode: 500)),
      );

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      final vm = container.read(cartViewModelProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockGet);

      await vm.getCart();

      final st = container.read(cartViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.cartProducts, isEmpty);
      expect(st.error, 'fail');

      verify(() => mockGet()).called(1);
    });

    test('addToCart success -> returns true and refreshes cart', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      // 1) stub initial auto-load getCart (triggered in build)
      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      // 2) stub addToCart (typed)
      when(
        () => mockAdd(any<AddToCartParams>()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      final vm = container.read(cartViewModelProvider.notifier);

      // let Future.microtask(getCart) run
      await Future<void>.delayed(Duration.zero);

      // ignore that initial auto call
      clearInteractions(mockGet);

      // 3) this is the refresh after addToCart
      when(() => mockGet()).thenAnswer(
        (_) async => Right(<ProductEntity>[
          cartProduct(id: 'p1', price: 10, quantity: 2),
        ]),
      );

      final ok = await vm.addToCart('p1', 2);

      expect(ok, isTrue);
      expect(container.read(cartViewModelProvider).cartProducts.length, 1);

      verify(() => mockAdd(any<AddToCartParams>())).called(1);
      verify(() => mockGet()).called(1); // ONLY refresh
    });

    test('addToCart failure -> returns false and sets error', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      // IMPORTANT: build() auto-calls getCart, so ALWAYS stub this first
      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      // addToCart fails
      when(() => mockAdd(any<AddToCartParams>())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'add fail', statusCode: 400)),
      );

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      final vm = container.read(cartViewModelProvider.notifier);

      await Future<void>.delayed(Duration.zero);

      clearInteractions(mockGet);

      final ok = await vm.addToCart('p1', 2);

      expect(ok, isFalse);
      expect(container.read(cartViewModelProvider).error, 'add fail');

      verify(() => mockAdd(any<AddToCartParams>())).called(1);

      verifyNever(() => mockGet());
    });
    test('deleteFromCart success -> returns true and refreshes cart', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      // stub for init microtask getCart
      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      when(
        () => mockDel(any<DeleteCartItemParams>()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      final vm = container.read(cartViewModelProvider.notifier);

      // IMPORTANT: let init microtask run THEN clear it
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockGet);

      // refresh after delete
      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      final ok = await vm.deleteFromCart('c1');

      expect(ok, isTrue);

      verify(() => mockDel(any<DeleteCartItemParams>())).called(1);
      verify(() => mockGet()).called(1); // refresh only
    });
    test('clearCart success -> empties products and returns true', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      when(() => mockClear()).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      final vm = container.read(cartViewModelProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockGet);

      vm.state = CartState.initial().copyWith(
        cartProducts: <ProductEntity>[
          cartProduct(id: 'p1', price: 10, quantity: 1),
        ],
      );

      final ok = await vm.clearCart();

      expect(ok, isTrue);
      final st = container.read(cartViewModelProvider);
      expect(st.cartProducts, isEmpty);
      expect(st.error, isNull);

      verify(() => mockClear()).called(1);
    });

    test('changeQty does nothing when newQty < 1', () async {
      final mockGet = MockGetCartProductsUsecase();
      final mockAdd = MockAddToCartUsecase();
      final mockDel = MockDeleteCartItemUsecase();
      final mockClear = MockClearCartUsecase();
      final mockUpdate = MockUpdateCartQtyUsecase();

      when(
        () => mockGet(),
      ).thenAnswer((_) async => const Right(<ProductEntity>[]));

      final container = makeContainer(
        getCart: mockGet,
        add: mockAdd,
        del: mockDel,
        clear: mockClear,
        updateQty: mockUpdate,
      );
      addTearDown(container.dispose);

      final vm = container.read(cartViewModelProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockGet);

      vm.state = CartState.initial().copyWith(
        cartProducts: [cartProduct(id: 'p1', price: 10, quantity: 2)],
      );

      await vm.changeQty(itemId: 'p1', newQty: 0);

      expect(
        container.read(cartViewModelProvider).cartProducts.first.quantity,
        2,
      );
      verifyNever(() => mockUpdate(any<UpdateCartQtyParams>()));
    });

    test(
      'changeQty success -> optimistic qty updated and API called',
      () async {
        final mockGet = MockGetCartProductsUsecase();
        final mockAdd = MockAddToCartUsecase();
        final mockDel = MockDeleteCartItemUsecase();
        final mockClear = MockClearCartUsecase();
        final mockUpdate = MockUpdateCartQtyUsecase();

        when(
          () => mockGet(),
        ).thenAnswer((_) async => const Right(<ProductEntity>[]));

        when(
          () => mockUpdate(any<UpdateCartQtyParams>()),
        ).thenAnswer((_) async => const Right(true));

        final container = makeContainer(
          getCart: mockGet,
          add: mockAdd,
          del: mockDel,
          clear: mockClear,
          updateQty: mockUpdate,
        );
        addTearDown(container.dispose);

        final vm = container.read(cartViewModelProvider.notifier);
        await Future<void>.delayed(Duration.zero);
        clearInteractions(mockGet);

        vm.state = CartState.initial().copyWith(
          cartProducts: [cartProduct(id: 'p1', price: 10, quantity: 1)],
        );

        await vm.changeQty(itemId: 'p1', newQty: 5);

        final st = container.read(cartViewModelProvider);
        expect(st.cartProducts.first.quantity, 5);

        verify(() => mockUpdate(any<UpdateCartQtyParams>())).called(1);
        verifyNever(() => mockGet()); // no rollback on success
      },
    );

    test(
      'changeQty failure -> calls getCart rollback and sets error',
      () async {
        final mockGet = MockGetCartProductsUsecase();
        final mockAdd = MockAddToCartUsecase();
        final mockDel = MockDeleteCartItemUsecase();
        final mockClear = MockClearCartUsecase();
        final mockUpdate = MockUpdateCartQtyUsecase();

        // init microtask getCart
        when(
          () => mockGet(),
        ).thenAnswer((_) async => const Right(<ProductEntity>[]));

        when(() => mockUpdate(any<UpdateCartQtyParams>())).thenAnswer(
          (_) async => Left(ApiFailure(message: 'qty fail', statusCode: 400)),
        );

        final container = makeContainer(
          getCart: mockGet,
          add: mockAdd,
          del: mockDel,
          clear: mockClear,
          updateQty: mockUpdate,
        );
        addTearDown(container.dispose);

        final vm = container.read(cartViewModelProvider.notifier);
        await Future<void>.delayed(Duration.zero);
        clearInteractions(mockGet);

        // rollback response (server truth)
        when(() => mockGet()).thenAnswer(
          (_) async => Right(<ProductEntity>[
            cartProduct(id: 'p1', price: 10, quantity: 2),
          ]),
        );

        vm.state = CartState.initial().copyWith(
          cartProducts: [cartProduct(id: 'p1', price: 10, quantity: 1)],
        );

        await vm.changeQty(itemId: 'p1', newQty: 5);

        // IMPORTANT: wait for the async rollback inside fold to finish
        await Future<void>.delayed(Duration.zero);

        final st = container.read(cartViewModelProvider);
        expect(st.cartProducts.first.quantity, 2); // matches rollback stub
        expect(st.error, 'qty fail');

        verify(() => mockUpdate(any<UpdateCartQtyParams>())).called(1);
        verify(() => mockGet()).called(1); // rollback only
      },
    );
  });
}
