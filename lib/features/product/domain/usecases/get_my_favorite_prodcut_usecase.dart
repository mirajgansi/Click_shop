import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMyFavoritesUsecaseProvider = Provider<GetMyFavoritesUsecase>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return GetMyFavoritesUsecase(repository);
});

class GetMyFavoritesUsecase {
  final IProductRepository _repository;

  GetMyFavoritesUsecase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call() {
    return _repository.getMyFavorites();
  }
}
