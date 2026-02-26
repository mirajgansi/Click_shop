import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addCommentUsecaseProvider = Provider<AddCommentUsecase>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return AddCommentUsecase(repository);
});

class AddCommentUsecase {
  final IProductRepository _repository;

  AddCommentUsecase(this._repository);

  Future<Either<Failure, ProductEntity>> call({
    required String productId,
    required String comment,
  }) {
    return _repository.addComment(productId: productId, comment: comment);
  }
}
