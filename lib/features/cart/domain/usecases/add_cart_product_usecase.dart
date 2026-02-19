import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/cart/data/repositories/cart_repositoy.dart';
import 'package:click_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddToCartParams extends Equatable {
  final String productId;
  final int quantity;

  const AddToCartParams({required this.productId, this.quantity = 1});

  @override
  List<Object?> get props => [productId, quantity];
}

final addToCartUsecaseProvider = Provider<AddToCartUsecase>((ref) {
  final repo = ref.read(cartRepositoryProvider);
  return AddToCartUsecase(cartRepository: repo);
});

class AddToCartUsecase implements UsecaseWithParams<bool, AddToCartParams> {
  final ICartRepository _repo;

  AddToCartUsecase({required ICartRepository cartRepository})
    : _repo = cartRepository;

  @override
  Future<Either<Failure, bool>> call(AddToCartParams params) {
    return _repo.createCartProduct(params.productId, params.quantity);
  }
}
