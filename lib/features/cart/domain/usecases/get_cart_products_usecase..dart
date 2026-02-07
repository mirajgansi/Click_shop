import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/cart/data/repositories/cart_repositoy.dart';
import 'package:click_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getCartProductsUsecaseProvider = Provider<GetCartProductsUsecase>((ref) {
  final repo = ref.read(cartRepositoryProvider);
  return GetCartProductsUsecase(cartRepository: repo);
});

class GetCartProductsUsecase
    implements UsecaseWithoutParams<List<ProductEntity>> {
  final ICartRepository _repo;

  GetCartProductsUsecase({required ICartRepository cartRepository})
    : _repo = cartRepository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call() {
    return _repo.getCartProducts();
  }
}
