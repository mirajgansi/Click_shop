import 'package:click_shop/features/product/domain/entities/product_entity.dart';

class ProductState {
  final bool isLoading;
  final List<ProductEntity> products;
  final String? error;

  const ProductState({
    required this.isLoading,
    required this.products,
    this.error,
  });

  factory ProductState.initial() {
    return const ProductState(isLoading: false, products: [], error: null);
  }

  ProductState copyWith({
    bool? isLoading,
    List<ProductEntity>? products,
    String? error,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
    );
  }
}
