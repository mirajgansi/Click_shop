import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetProductByIdParams extends Equatable {
  final String productId;

  const GetProductByIdParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final getProductByIdUsecaseProvider = Provider<GetProductByIdUsecase>((ref) {
  final itemRepository = ref.read(productRepositoryProvider);
  return GetProductByIdUsecase(itemRepository: itemRepository);
});

class GetProductByIdUsecase
    implements UsecaseWithParams<ProductEntity, GetProductByIdParams> {
  final IProductRepository _itemRepository;

  GetProductByIdUsecase({required IProductRepository itemRepository})
    : _itemRepository = itemRepository;

  @override
  Future<Either<Failure, ProductEntity>> call(GetProductByIdParams params) {
    return _itemRepository.getProductbyId(params.productId);
  }
}
