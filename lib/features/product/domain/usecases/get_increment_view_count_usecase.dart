import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final incrementViewCountUsecaseProvider = Provider<IncrementViewCountUsecase>((
  ref,
) {
  final repository = ref.read(productRepositoryProvider);
  return IncrementViewCountUsecase(repository);
});

class IncrementViewCountUsecase {
  final IProductRepository _repository;

  IncrementViewCountUsecase(this._repository);

  Future<Either<Failure, bool>> call(String productId) {
    return _repository.incrementViewCount(productId);
  }
}
