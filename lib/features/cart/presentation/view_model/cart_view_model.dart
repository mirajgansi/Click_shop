import 'package:click_shop/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/clear_cart_prodcut_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/create_order_cart_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/delete_cart_product_usecase.dart';
import 'package:click_shop/features/cart/domain/usecases/get_cart_products_usecase..dart';
import 'package:click_shop/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:click_shop/features/cart/presentation/state/cart_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartViewModelProvider = NotifierProvider<CartViewModel, CartState>(
  CartViewModel.new,
);

class CartViewModel extends Notifier<CartState> {
  late final GetCartProductsUsecase _getCartProductsUsecase;
  late final AddToCartUsecase _addToCartUsecase;
  late final DeleteCartItemUsecase _deleteCartItemUsecase;
  late final ClearCartUsecase _clearCartUsecase;
  late final CreateOrderFromCartUsecase _createOrderFromCartUsecase;
  late final UpdateCartQtyUsecase _updateCartQtyUsecase;

  @override
  CartState build() {
    _getCartProductsUsecase = ref.read(getCartProductsUsecaseProvider);
    _addToCartUsecase = ref.read(addToCartUsecaseProvider);
    _deleteCartItemUsecase = ref.read(deleteCartItemUsecaseProvider);
    _updateCartQtyUsecase = ref.read(updateCartQtyUsecaseProvider);

    // _clearCartUsecase = ref.read(clearCartUsecaseProvider);
    // _createOrderFromCartUsecase = ref.read(createOrderFromCartUsecaseProvider);

    // auto load cart once
    Future.microtask(getCart);

    return CartState.initial();
  }

  num get totalPrice {
    num total = 0;
    for (final p in state.cartProducts) {
      total += (p.price ?? 0); // ⚠️ qty not included yet
    }
    return total;
  }

  Future<void> getCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCartProductsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        cartProducts: [],
      ),
      (products) => state = state.copyWith(
        isLoading: false,
        cartProducts: products,
        error: null,
      ),
    );
  }

  Future<bool> addToCart(String productId, int quantity) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _addToCartUsecase(
      AddToCartParams(productId: productId, quantity: quantity),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(isLoading: false, error: null);
        await getCart(); // refresh
        return true;
      },
    );
  }

  Future<bool> deleteFromCart(String productId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _deleteCartItemUsecase(
      DeleteCartItemParams(cartItemId: productId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(isLoading: false, error: null);
        await getCart();
        return true;
      },
    );
  }

  Future<bool> clearCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _clearCartUsecase();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(isLoading: false, error: null, cartProducts: []);
        return true;
      },
    );
  }

  Future<bool> orderFromCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createOrderFromCartUsecase();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) async {
        state = state.copyWith(isLoading: false, error: null, cartProducts: []);
        return true;
      },
    );
  }

  Future<void> changeQty({required String itemId, required int newQty}) async {
    // optimistic UI update
    state = state.copyWith(
      cartProducts: [
        for (final item in state.cartProducts)
          if (item.id == itemId) item.copyWith(quantity: newQty) else item,
      ],
    );

    final result = await _updateCartQtyUsecase(
      UpdateCartQtyParams(cartItemId: itemId, quantity: newQty),
    );

    result.fold((failure) async {
      // rollback
      await getCart();
      state = state.copyWith(error: failure.message);
    }, (_) {});
  }
}
