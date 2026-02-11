import 'package:click_shop/features/product/domain/entities/product_entity.dart';

class ProductState {
  final bool isLoading;
  final String? error;

  final List<ProductEntity> allProducts; // ✅ home
  final List<ProductEntity> categoryProducts; // ✅ category screen

  final ProductEntity? selectedProduct;

  const ProductState({
    required this.isLoading,
    required this.error,
    required this.allProducts,
    required this.categoryProducts,
    required this.selectedProduct,
  });

  factory ProductState.initial() => const ProductState(
    isLoading: false,
    error: null,
    allProducts: [],
    categoryProducts: [],
    selectedProduct: null,
  );

  ProductState copyWith({
    bool? isLoading,
    String? error,
    List<ProductEntity>? allProducts,
    List<ProductEntity>? categoryProducts,
    ProductEntity? selectedProduct,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allProducts: allProducts ?? this.allProducts,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }
}
