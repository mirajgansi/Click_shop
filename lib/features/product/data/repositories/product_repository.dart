import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/data/datasources/local/product_local_database.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Provider
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final productDatasource = ref.watch(ProductDatasourceProvider);
  return ProductRepository();
});

class ProductRepository implements IProductRepository {
  @override
  Future<Either<Failure, bool>> createProduct(ProductEntity productEntity) {
    // TODO: implement createProduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> delteProduct(String productId) {
    // TODO: implement delteProduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> favoriteProduct(String productId) {
    // TODO: implement favoriteProduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> getAllproduct() {
    // TODO: implement getAllproduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavoriteProducts() {
    // TODO: implement getFavoriteProducts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductbyId(String productId) {
    // TODO: implement getProductbyId
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId,
  ) {
    // TODO: implement getProductsByCategory
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query) {
    // TODO: implement searchProducts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateProduct(ProductEntity productEntity) {
    // TODO: implement updateProduct
    throw UnimplementedError();
  }

  // Repository methods and properties go here
}
