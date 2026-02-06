import 'package:click_shop/features/product/domain/entities/product_entity.dart';

class ProductState {
  final bool isLoading;
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String? error;

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.selectedProduct,
    this.error,
  });

  factory ProductState.initial() => const ProductState();

  ProductState copyWith({
    bool? isLoading,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? error,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      error: error,
    );
  }
}
