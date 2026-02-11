import 'package:click_shop/features/product/domain/usecases/get_all_prodcut_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_category_product_usecase.dart';
import 'package:click_shop/features/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:click_shop/features/product/presentation/state/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(ProductViewModel.new);

class ProductViewModel extends Notifier<ProductState> {
  late final GetAllProductsUsecase _getAllProductsUsecase;
  late final GetProductByIdUsecase _getProductByIdUsecase;
  late final GetProductsByCategoryUsecase _getProductsByCategoryUsecase;

  @override
  ProductState build() {
    _getAllProductsUsecase = ref.read(getAllProductUsecaseProvider);
    _getProductByIdUsecase = ref.read(getProductByIdUsecaseProvider);
    _getProductsByCategoryUsecase = ref.read(
      getProductsByCategoryUsecaseProvider,
    );

    Future.microtask(loadProducts);

    return ProductState.initial();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAllProductsUsecase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        allProducts: products, // ✅ store in allProducts
        error: null,
      ),
    );
  }

  Future<void> getProductById(String productId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getProductByIdUsecase(
      GetProductByIdParams(productId: productId),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (product) => state = state.copyWith(
        isLoading: false,
        selectedProduct: product,
        error: null,
      ),
    );
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getProductsByCategoryUsecase(categoryId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        categoryProducts: products, // ✅ store separately
        error: null,
      ),
    );
  }
}
