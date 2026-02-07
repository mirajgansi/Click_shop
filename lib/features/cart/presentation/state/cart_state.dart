import 'package:click_shop/features/product/domain/entities/product_entity.dart';

class CartState {
  final bool isLoading;
  final String? error;
  final List<ProductEntity> cartProducts;

  const CartState({
    required this.isLoading,
    required this.cartProducts,
    this.error,
  });

  factory CartState.initial() {
    return const CartState(isLoading: false, cartProducts: [], error: null);
  }

  CartState copyWith({
    bool? isLoading,
    String? error,
    List<ProductEntity>? cartProducts,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cartProducts: cartProducts ?? this.cartProducts,
    );
  }
}
