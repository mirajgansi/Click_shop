import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getTrendingProductsUsecaseProvider = Provider<GetTrendingProductsUsecase>(
  (ref) {
    final repo = ref.read(productRepositoryProvider);
    return GetTrendingProductsUsecase(productRepository: repo);
  },
);

class GetTrendingProductsUsecase
    implements UsecaseWithoutParams<List<ProductEntity>> {
  final IProductRepository _productRepository;

  GetTrendingProductsUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call() {
    return _productRepository.getTrendingProducts();
  }
}
