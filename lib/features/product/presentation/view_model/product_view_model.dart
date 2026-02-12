import 'package:click_shop/features/product/domain/usecases/ger_trending_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_all_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_category_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_popular_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_recent_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/search_product_usecase.dart';

import 'package:click_shop/features/product/presentation/state/product_state.dart';
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
  // late final GetTopRatedProductsUsecase _getTopRatedProductsUsecase;

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
    // _getTopRatedProductsUsecase = ref.read(getTopRatedProductsUsecaseProvider);

    Future.microtask(() async {
      await loadProducts();
      await loadHomeSections(); // recent/trending/popular/topRated
    });

    return ProductState.initial();
  }

  // -------------------- ALL PRODUCTS --------------------
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
  }

  // -------------------- HOME SECTIONS (4 calls) --------------------
  Future<void> loadHomeSections() async {
    // You can run these in parallel
    await Future.wait([
      loadRecent(),
      loadTrending(),
      loadPopular(),
      // loadTopRated(),
    ]);
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

  // Future<void> loadTopRated() async {
  //   state = state.copyWith(isTopRatedLoading: true, clearError: true);

  //   final result = await _getTopRatedProductsUsecase();

  //   result.fold(
  //     (failure) => state = state.copyWith(
  //       isTopRatedLoading: false,
  //       error: failure.message,
  //     ),
  //     (products) => state = state.copyWith(
  //       isTopRatedLoading: false,
  //       topRatedProducts: products,
  //       clearError: true,
  //     ),
  //   );
  // }

  // -------------------- PRODUCT BY ID --------------------
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

  // -------------------- CATEGORY PRODUCTS --------------------
  Future<void> loadProductsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // If your usecase expects params object, use that.
    // You currently call it like: _getProductsByCategoryUsecase(categoryId)
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

  // -------------------- SEARCH --------------------
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
}
