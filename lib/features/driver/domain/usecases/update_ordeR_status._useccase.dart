import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/driver/data/repositories/driver_repository.dart';
import 'package:click_shop/features/driver/domain/repositories/driver_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final updateOrderStatusUsecaseProvider = Provider<UpdateOrderStatusUsecase>((
  ref,
) {
  final repo = ref.read(driverRepositoryProvider);
  return UpdateOrderStatusUsecase(repo);
});

class UpdateOrderStatusUsecase {
  final IDriverRepository _repository;

  UpdateOrderStatusUsecase(this._repository);

  Future<Either<Failure, bool>> call({
    required String orderId,
    required String status,
  }) {
    return _repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
