import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/order/data/repositories/order_repository.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMyOrdersUsecaseProvider = Provider<GetMyOrdersUsecase>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return GetMyOrdersUsecase(orderRepository: repo);
});

class GetMyOrdersUsecase implements UsecaseWithoutParams<List<OrderEntity>> {
  final IOrderRepository _repo;

  GetMyOrdersUsecase({required IOrderRepository orderRepository})
    : _repo = orderRepository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call() {
    return _repo.getMyOrders();
  }
}
