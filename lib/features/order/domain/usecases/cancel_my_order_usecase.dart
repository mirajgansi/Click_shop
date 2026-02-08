import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/order/data/repositories/order_repository.dart';
import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CancelOrderParams extends Equatable {
  final String orderId;

  const CancelOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

final cancelMyOrderUsecaseProvider = Provider<CancelMyOrderUsecase>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return CancelMyOrderUsecase(orderRepository: repo);
});

class CancelMyOrderUsecase
    implements UsecaseWithParams<bool, CancelOrderParams> {
  final IOrderRepository _repo;

  CancelMyOrderUsecase({required IOrderRepository orderRepository})
    : _repo = orderRepository;

  @override
  Future<Either<Failure, bool>> call(CancelOrderParams params) {
    return _repo.cancelMyOrder(params.orderId);
  }
}
