import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/driver/data/repositories/driver_repository.dart';
import 'package:click_shop/features/driver/domain/repositories/driver_repository.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final getMyAssignedOrdersUsecaseProvider = Provider<GetMyAssignedOrdersUsecase>(
  (ref) {
    final repo = ref.read(driverRepositoryProvider);
    return GetMyAssignedOrdersUsecase(repo);
  },
);

class GetMyAssignedOrdersUsecase {
  final IDriverRepository _repository;

  GetMyAssignedOrdersUsecase(this._repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return _repository.getMyAssignedOrders();
  }
}
