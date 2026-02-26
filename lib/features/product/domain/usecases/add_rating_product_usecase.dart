import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rateProductUsecaseProvider = Provider<RateProductUsecase>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return RateProductUsecase(repository);
});

class RateProductUsecase {
  final IProductRepository _repository;

  RateProductUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call({
    required String productId,
    required double rating,
  }) {
    return _repository.rateProduct(productId: productId, rating: rating);
  }
}
