import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getProductsByCategoryUsecaseProvider =
    Provider<GetProductsByCategoryUsecase>((ref) {
      final repo = ref.read(productRepositoryProvider);
      return GetProductsByCategoryUsecase(repo);
    });

class GetProductsByCategoryUsecase {
  final IProductRepository _repo;

  GetProductsByCategoryUsecase(this._repo);

  Future<Either<Failure, List<ProductEntity>>> call(String categoryId) {
    return _repo.getProductsByCategory(categoryId);
  }
}
