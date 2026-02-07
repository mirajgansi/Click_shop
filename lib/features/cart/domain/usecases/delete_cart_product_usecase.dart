import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/cart/data/repositories/cart_repositoy.dart';
import 'package:click_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteCartItemParams extends Equatable {
  final String cartItemId;

  const DeleteCartItemParams({required this.cartItemId});

  @override
  List<Object?> get props => [cartItemId];
}

final deleteCartItemUsecaseProvider = Provider<DeleteCartItemUsecase>((ref) {
  final repo = ref.read(cartRepositoryProvider);
  return DeleteCartItemUsecase(cartRepository: repo);
});

class DeleteCartItemUsecase
    implements UsecaseWithParams<bool, DeleteCartItemParams> {
  final ICartRepository _repo;

  DeleteCartItemUsecase({required ICartRepository cartRepository})
    : _repo = cartRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteCartItemParams params) {
    return _repo.deleteCartItem(params.cartItemId);
  }
}
