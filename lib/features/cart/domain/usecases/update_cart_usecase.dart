import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/cart/data/repositories/cart_repositoy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../repositories/cart_repository.dart';

final updateCartQtyUsecaseProvider = Provider<UpdateCartQtyUsecase>((ref) {
  return UpdateCartQtyUsecase(ref.read(cartRepositoryProvider));
});

class UpdateCartQtyParams {
  final String cartItemId;
  final int quantity;

  UpdateCartQtyParams({required this.cartItemId, required this.quantity});
}

class UpdateCartQtyUsecase {
  final ICartRepository repository;

  UpdateCartQtyUsecase(this.repository);

  Future<Either<Failure, void>> call(UpdateCartQtyParams params) {
    return repository.updateCartQty(
      cartItemId: params.cartItemId,
      quantity: params.quantity,
    );
  }
}
