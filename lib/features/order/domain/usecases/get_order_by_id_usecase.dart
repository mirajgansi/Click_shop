import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/order/data/repositories/order_repository.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetOrderByIdParams extends Equatable {
  final String orderId;

  const GetOrderByIdParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final getOrderByIdUsecaseProvider = Provider<GetOrderByIdUsecase>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return GetOrderByIdUsecase(orderRepository: repo);
});

class GetOrderByIdUsecase
    implements UsecaseWithParams<OrderEntity, GetOrderByIdParams> {
  final IOrderRepository _repo;

  GetOrderByIdUsecase({required IOrderRepository orderRepository})
    : _repo = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) {
    return _repo.getOrderById(params.orderId);
  }
}
