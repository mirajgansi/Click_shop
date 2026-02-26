import 'package:click_shop/features/product/domain/entities/product_entity.dart';

class ProductState {
  final bool isLoading;
  final String? error;

  final List<ProductEntity> allProducts;
  final List<ProductEntity> categoryProducts;
  final ProductEntity? selectedProduct;

  final bool isRecentLoading;
  final bool isTrendingLoading;
  final bool isPopularLoading;
  final bool isTopRatedLoading;

  final List<ProductEntity> recentProducts;
  final List<ProductEntity> trendingProducts;
  final List<ProductEntity> popularProducts;
  final List<ProductEntity> topRatedProducts;

  final bool isProductActionLoading;

  final List<ProductEntity> favoriteProducts;

  final bool isCommentsLoading;
  final List<ProductCommentEntity> comments;

  const ProductState({
    required this.isLoading,
    required this.error,
    required this.allProducts,
    required this.categoryProducts,
    required this.selectedProduct,
    required this.isRecentLoading,
    required this.isTrendingLoading,
    required this.isPopularLoading,
    required this.isTopRatedLoading,
    required this.recentProducts,
    required this.trendingProducts,
    required this.popularProducts,
    required this.topRatedProducts,

    required this.isProductActionLoading,
    required this.favoriteProducts,
    required this.isCommentsLoading,
    required this.comments,
  });

  factory ProductState.initial() => const ProductState(
    isLoading: false,
    error: null,
    allProducts: [],
    categoryProducts: [],
    selectedProduct: null,
    isRecentLoading: false,
    isTrendingLoading: false,
    isPopularLoading: false,
    isTopRatedLoading: false,
    recentProducts: [],
    trendingProducts: [],
    popularProducts: [],
    topRatedProducts: [],
    isProductActionLoading: false,
    favoriteProducts: [],
    isCommentsLoading: false,
    comments: [],
  );

  ProductState copyWith({
    bool? isLoading,
    String? error,

    List<ProductEntity>? allProducts,
    List<ProductEntity>? categoryProducts,
    ProductEntity? selectedProduct,

    bool? isRecentLoading,
    bool? isTrendingLoading,
    bool? isPopularLoading,
    bool? isTopRatedLoading,

    List<ProductEntity>? recentProducts,
    List<ProductEntity>? trendingProducts,
    List<ProductEntity>? popularProducts,
    List<ProductEntity>? topRatedProducts,

    bool? isProductActionLoading,
    List<ProductEntity>? favoriteProducts,

    bool? isCommentsLoading,
    List<ProductCommentEntity>? comments,

    bool clearError = false,
    bool clearSelectedProduct = false,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),

      allProducts: allProducts ?? this.allProducts,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedProduct: clearSelectedProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),

      isRecentLoading: isRecentLoading ?? this.isRecentLoading,
      isTrendingLoading: isTrendingLoading ?? this.isTrendingLoading,
      isPopularLoading: isPopularLoading ?? this.isPopularLoading,
      isTopRatedLoading: isTopRatedLoading ?? this.isTopRatedLoading,

      recentProducts: recentProducts ?? this.recentProducts,
      trendingProducts: trendingProducts ?? this.trendingProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      topRatedProducts: topRatedProducts ?? this.topRatedProducts,

      isProductActionLoading:
          isProductActionLoading ?? this.isProductActionLoading,

      favoriteProducts: favoriteProducts ?? this.favoriteProducts,

      isCommentsLoading: isCommentsLoading ?? this.isCommentsLoading,
      comments: comments ?? this.comments,
    );
  }
}
