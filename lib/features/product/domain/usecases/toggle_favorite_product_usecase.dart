import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toggleFavoriteUsecaseProvider = Provider<ToggleFavoriteUsecase>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return ToggleFavoriteUsecase(repository);
});

class ToggleFavoriteUsecase {
  final IProductRepository _repository;

  ToggleFavoriteUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call({required String productId}) {
    return _repository.toggleFavorite(productId: productId);
  }
}
