import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/usecases/add_comment_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/add_rating_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/ger_trending_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_all_comment_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_all_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_category_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_increment_view_count_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_my_favorite_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_popular_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_recent_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/search_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/toggle_favorite_product_usecase.dart';
import 'package:click_shop/features/product/presentation/state/product_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(ProductViewModel.new);

class ProductViewModel extends Notifier<ProductState> {
  late final GetAllProductsUsecase _getAllProductsUsecase;
  late final GetProductByIdUsecase _getProductByIdUsecase;
  late final GetProductsByCategoryUsecase _getProductsByCategoryUsecase;
  late final SearchProductsUsecase _searchProductsUsecase;
  late final GetRecentProductsUsecase _getRecentProductsUsecase;
  late final GetTrendingProductsUsecase _getTrendingProductsUsecase;
  late final GetPopularProductsUsecase _getPopularProductsUsecase;
  late final IncrementViewCountUsecase _incrementViewCountUsecase;

  late final RateProductUsecase _rateProductUsecase;
  late final ToggleFavoriteUsecase _toggleFavoriteUsecase;
  late final AddCommentUsecase _addCommentUsecase;
  late final GetProductCommentsUsecase _getProductCommentsUsecase;
  late final GetMyFavoritesUsecase _getMyFavoritesUsecase;

  @override
  ProductState build() {
    _getAllProductsUsecase = ref.read(getAllProductUsecaseProvider);
    _getProductByIdUsecase = ref.read(getProductByIdUsecaseProvider);
    _getProductsByCategoryUsecase = ref.read(
      getProductsByCategoryUsecaseProvider,
    );
    _searchProductsUsecase = ref.read(searchProductsUsecaseProvider);

    _getRecentProductsUsecase = ref.read(getRecentProductsUsecaseProvider);
    _getTrendingProductsUsecase = ref.read(getTrendingProductsUsecaseProvider);
    _getPopularProductsUsecase = ref.read(getPopularProductsUsecaseProvider);

    _incrementViewCountUsecase = ref.read(incrementViewCountUsecaseProvider);

    // ✅ new
    _rateProductUsecase = ref.read(rateProductUsecaseProvider);
    _toggleFavoriteUsecase = ref.read(toggleFavoriteUsecaseProvider);
    _addCommentUsecase = ref.read(addCommentUsecaseProvider);
    _getProductCommentsUsecase = ref.read(getProductCommentsUsecaseProvider);
    _getMyFavoritesUsecase = ref.read(getMyFavoritesUsecaseProvider);

    return ProductState.initial();
  }

  Future<void> initHome() async {
    debugPrint("initHome called");
    await Future.wait([
      loadProducts(),
      loadRecent(),
      loadTrending(),
      loadPopular(),
    ]);
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllProductsUsecase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        allProducts: products,
        clearError: true,
      ),
    );

    debugPrint("allProducts SET: ${state.allProducts.length}");
  }

  Future<void> loadRecent() async {
    state = state.copyWith(isRecentLoading: true, clearError: true);

    final result = await _getRecentProductsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        isRecentLoading: false,
        error: failure.message,
      ),
      (products) => state = state.copyWith(
        isRecentLoading: false,
        recentProducts: products,
        clearError: true,
      ),
    );
  }

  Future<void> loadTrending() async {
    state = state.copyWith(isTrendingLoading: true, clearError: true);

    final result = await _getTrendingProductsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        isTrendingLoading: false,
        error: failure.message,
      ),
      (products) => state = state.copyWith(
        isTrendingLoading: false,
        trendingProducts: products,
        clearError: true,
      ),
    );
  }

  Future<void> loadPopular() async {
    state = state.copyWith(isPopularLoading: true, clearError: true);

    final result = await _getPopularProductsUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        isPopularLoading: false,
        error: failure.message,
      ),
      (products) => state = state.copyWith(
        isPopularLoading: false,
        popularProducts: products,
        clearError: true,
      ),
    );
  }

  Future<void> incrementView(String productId) async {
    await _incrementViewCountUsecase(productId);
  }

  Future<void> getProductById(String productId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getProductByIdUsecase(
      GetProductByIdParams(productId: productId),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (product) => state = state.copyWith(
        isLoading: false,
        selectedProduct: product,
        clearError: true,
      ),
    );
  }

  void clearSelectedProduct() {
    state = state.copyWith(clearSelectedProduct: true);
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getProductsByCategoryUsecase(categoryId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        categoryProducts: products,
        clearError: true,
      ),
    );
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _searchProductsUsecase(
      SearchProductsParams(query: query, page: 1, size: 20),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        allProducts: products,
        clearError: true,
      ),
    );
  }

  // ===================== NEW FEATURES =====================

  Future<void> rateProduct({
    required String productId,
    required double rating,
  }) async {
    state = state.copyWith(isProductActionLoading: true, clearError: true);

    final result = await _rateProductUsecase(
      productId: productId,
      rating: rating,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isProductActionLoading: false,
        error: failure.message,
      ),
      (updatedProduct) => state = state.copyWith(
        isProductActionLoading: false,
        selectedProduct: updatedProduct,
        clearError: true,
      ),
    );
  }

  Future<void> toggleFavorite({required String productId}) async {
    state = state.copyWith(isProductActionLoading: true, clearError: true);

    final result = await _toggleFavoriteUsecase(productId: productId);

    result.fold(
      (failure) => state = state.copyWith(
        isProductActionLoading: false,
        error: failure.message,
      ),
      (updatedProduct) {
        List<ProductEntity> updateList(List<ProductEntity> list) {
          return list
              .map((p) => (p.id == updatedProduct.id) ? updatedProduct : p)
              .toList();
        }

        state = state.copyWith(
          isProductActionLoading: false,
          selectedProduct: updatedProduct,
          allProducts: updateList(state.allProducts),
          recentProducts: updateList(state.recentProducts),
          trendingProducts: updateList(state.trendingProducts),
          popularProducts: updateList(state.popularProducts),
          categoryProducts: updateList(state.categoryProducts),
          favoriteProducts: updateList(state.favoriteProducts),
          clearError: true,
        );
      },
    );
  }

  Future<void> loadMyFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getMyFavoritesUsecase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (items) => state = state.copyWith(
        isLoading: false,
        favoriteProducts: items,
        clearError: true,
      ),
    );
  }

  Future<void> loadComments(String productId) async {
    state = state.copyWith(isCommentsLoading: true, clearError: true);

    final result = await _getProductCommentsUsecase(productId: productId);
    result.fold(
      (failure) => state = state.copyWith(
        isCommentsLoading: false,
        error: failure.message,
      ),
      (items) {
        debugPrint(
          "First comment username: ${items.isNotEmpty ? items.first.username : 'none'}",
        );
        state = state.copyWith(
          isCommentsLoading: false,
          comments: items,
          clearError: true,
        );
      },
    );
  }

  Future<void> addComment({
    required String productId,
    required String comment,
  }) async {
    state = state.copyWith(isProductActionLoading: true, clearError: true);

    final result = await _addCommentUsecase(
      productId: productId,
      comment: comment,
    );
    result.fold(
      (failure) => state = state.copyWith(
        isProductActionLoading: false,
        error: failure.message,
      ),
      (updatedProduct) {
        // update selected product + refresh comments list from product (if backend returns it)
        state = state.copyWith(
          isProductActionLoading: false,
          selectedProduct: updatedProduct,
          comments: updatedProduct.comments,
          clearError: true,
        );
      },
    );
  }
}
