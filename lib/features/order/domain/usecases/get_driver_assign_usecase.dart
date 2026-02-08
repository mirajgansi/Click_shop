// import 'package:click_shop/core/error/failures.dart';
// import 'package:click_shop/core/usecase/app_usecase.dart';
// import 'package:click_shop/features/order/domain/entities/order_entities.dart';
// import 'package:click_shop/features/order/domain/repositories/order_repository.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final getDriverOrdersUsecaseProvider =
//     Provider<GetDriverOrdersUsecase>((ref) {
//   final repo = ref.read(orderRepositoryProvider);
//   return GetDriverOrdersUsecase(orderRepository: repo);
// });

// class GetDriverOrdersUsecase
//     implements UsecaseWithoutParams<List<OrderEntity>> {
//   final IOrderRepository _repo;

//   GetDriverOrdersUsecase({
//     required IOrderRepository orderRepository,
//   }) : _repo = orderRepository;

//   @override
//   Future<Either<Failure, List<OrderEntity>>> call() {
//     return _repo.getDriverOrders();
//   }
// }
