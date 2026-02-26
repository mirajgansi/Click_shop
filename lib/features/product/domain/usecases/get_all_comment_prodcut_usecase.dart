import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getProductCommentsUsecaseProvider = Provider<GetProductCommentsUsecase>((
  ref,
) {
  final repository = ref.read(productRepositoryProvider);
  return GetProductCommentsUsecase(repository);
});

class GetProductCommentsUsecase {
  final IProductRepository _repository;

  GetProductCommentsUsecase(this._repository);

  Future<Either<Failure, List<ProductCommentEntity>>> call({
    required String productId,
  }) {
    return _repository.getProductComments(productId: productId);
  }
}
