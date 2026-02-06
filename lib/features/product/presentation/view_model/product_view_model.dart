import 'package:click_shop/features/product/domain/usecases/get_all_prodcut_usecase.dart';
import 'package:click_shop/features/product/presentation/state/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(ProductViewModel.new);

class ProductViewModel extends Notifier<ProductState> {
  late final GetAllProductsUsecase _getAllProductsUsecase;

  @override
  ProductState build() {
    _getAllProductsUsecase = ref.read(getAllProductUsecaseProvider);

    // auto-load after build (safe)
    Future.microtask(loadProducts);

    return ProductState.initial();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAllProductsUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (products) {
        state = state.copyWith(
          isLoading: false,
          products: products,
          error: null,
        );
      },
    );
  }
}
