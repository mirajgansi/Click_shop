import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchProductsParams extends Equatable {
  final String query;
  final int page;
  final int size;

  const SearchProductsParams({
    required this.query,
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [query, page, size];
}

final searchProductsUsecaseProvider = Provider<SearchProductsUsecase>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return SearchProductsUsecase(productRepository: repo);
});

class SearchProductsUsecase
    implements UsecaseWithParams<List<ProductEntity>, SearchProductsParams> {
  final IProductRepository _productRepository;

  SearchProductsUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
    SearchProductsParams params,
  ) {
    return _productRepository.searchProducts(
      query: params.query,
      page: params.page,
      size: params.size,
    );
  }
}
