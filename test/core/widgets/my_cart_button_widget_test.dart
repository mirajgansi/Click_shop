import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/widgets/my_cart_button_widget.dart';
import 'package:click_shop/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/clear_cart_prodcut_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/delete_cart_product_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/get_cart_products_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCartProductsUsecase extends Mock
    implements GetCartProductsUsecase {}

class MockAddToCartUsecase extends Mock implements AddToCartUsecase {}

class MockDeleteCartItemUsecase extends Mock implements DeleteCartItemUsecase {}

class MockClearCartUsecase extends Mock implements ClearCartUsecase {}

class MockUpdateCartQtyUsecase extends Mock implements UpdateCartQtyUsecase {}

class FakeAddToCartParams extends Fake implements AddToCartParams {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeAddToCartParams());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key == 'assets/icons/bx_cart-add.svg') {
            const svg =
                '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"></svg>';
            return ByteData.view(Uint8List.fromList(utf8.encode(svg)).buffer);
          }
          return null;
        });
  });

  Widget createWidget({
    required MockGetCartProductsUsecase mockGet,
    required MockAddToCartUsecase mockAdd,
    required MockDeleteCartItemUsecase mockDel,
    required MockClearCartUsecase mockClear,
    required MockUpdateCartQtyUsecase mockUpdate,
  }) {
    return ProviderScope(
      overrides: [
        getCartProductsUsecaseProvider.overrideWithValue(mockGet),
        addToCartUsecaseProvider.overrideWithValue(mockAdd),
        deleteCartItemUsecaseProvider.overrideWithValue(mockDel),
        clearCartUsecaseProvider.overrideWithValue(mockClear),
        updateCartQtyUsecaseProvider.overrideWithValue(mockUpdate),
      ],
      child: const MaterialApp(
        home: Scaffold(body: MyCartButtonWidget(productId: 'p1')),
      ),
    );
  }

  testWidgets('renders cart button', (tester) async {
    final mockGet = MockGetCartProductsUsecase();
    final mockAdd = MockAddToCartUsecase();
    final mockDel = MockDeleteCartItemUsecase();
    final mockClear = MockClearCartUsecase();
    final mockUpdate = MockUpdateCartQtyUsecase();

    when(
      () => mockGet(),
    ).thenAnswer((_) async => const Right(<ProductEntity>[]));
    when(
      () => mockAdd(any<AddToCartParams>()),
    ).thenAnswer((_) async => const Right(true));

    await tester.pumpWidget(
      createWidget(
        mockGet: mockGet,
        mockAdd: mockAdd,
        mockDel: mockDel,
        mockClear: mockClear,
        mockUpdate: mockUpdate,
      ),
    );

    await tester.pump();

    expect(find.byType(MyCartButtonWidget), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows loading indicator while request is running', (
    tester,
  ) async {
    final mockGet = MockGetCartProductsUsecase();
    final mockAdd = MockAddToCartUsecase();
    final mockDel = MockDeleteCartItemUsecase();
    final mockClear = MockClearCartUsecase();
    final mockUpdate = MockUpdateCartQtyUsecase();
    final completer = Completer<Either<Failure, bool>>();

    when(
      () => mockGet(),
    ).thenAnswer((_) async => const Right(<ProductEntity>[]));
    when(
      () => mockAdd(any<AddToCartParams>()),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      createWidget(
        mockGet: mockGet,
        mockAdd: mockAdd,
        mockDel: mockDel,
        mockClear: mockClear,
        mockUpdate: mockUpdate,
      ),
    );

    await tester.pump();
    clearInteractions(mockGet);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Right(true));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Item addded to cart'), findsOneWidget);
  });
}
