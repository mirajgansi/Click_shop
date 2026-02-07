import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/cart/data/repositories/cart_repositoy.dart';
import 'package:click_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createOrderFromCartUsecaseProvider = Provider<CreateOrderFromCartUsecase>(
  (ref) {
    final repo = ref.read(cartRepositoryProvider);
    return CreateOrderFromCartUsecase(cartRepository: repo);
  },
);

class CreateOrderFromCartUsecase implements UsecaseWithoutParams<bool> {
  final ICartRepository _repo;

  CreateOrderFromCartUsecase({required ICartRepository cartRepository})
    : _repo = cartRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _repo.createOrderFromCart();
  }
}
