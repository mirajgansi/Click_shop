import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/order/data/repositories/order_repository.dart';
import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createOrderFromCartUsecaseProvider = Provider<CreateOrderFromCartUsecase>(
  (ref) {
    final repo = ref.read(orderRepositoryProvider);
    return CreateOrderFromCartUsecase(orderRepository: repo);
  },
);

class CreateOrderParams {
  final Map<String, dynamic> shippingJson;
  const CreateOrderParams(this.shippingJson);
}

class CreateOrderFromCartUsecase
    implements UsecaseWithParams<bool, CreateOrderParams> {
  final IOrderRepository _repo;
  CreateOrderFromCartUsecase({required IOrderRepository orderRepository})
    : _repo = orderRepository;

  @override
  Future<Either<Failure, bool>> call(CreateOrderParams params) {
    return _repo.createOrderFromCart(params.shippingJson);
  }
}
