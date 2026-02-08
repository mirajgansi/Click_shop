import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/cart/data/repositories/cart_repositoy.dart';
import 'package:click_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

final updateCartQtyUsecaseProvider = Provider<UpdateCartQtyUsecase>((ref) {
  return UpdateCartQtyUsecase(ref.read(cartRepositoryProvider));
});

class UpdateCartQtyParams {
  final String productId;
  final int quantity;

  UpdateCartQtyParams({required this.productId, required this.quantity});
}

class UpdateCartQtyUsecase {
  final ICartRepository repository;

  UpdateCartQtyUsecase(this.repository);

  Future<Either<Failure, void>> call(UpdateCartQtyParams params) {
    return repository.updateCartQty(
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}
