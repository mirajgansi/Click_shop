import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IProductRepository {
  Future<Either<Failure, bool>> createProduct(ProductEntity productEntity);
  Future<Either<Failure, List<ProductEntity>>> getAllproduct();
  Future<Either<Failure, ProductEntity>> getProductbyId(String productId);
  Future<Either<Failure, bool>> delteProduct(String productId);
  Future<Either<Failure, bool>> updateProduct(ProductEntity productEntity);
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId,
  );
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);
  Future<Either<Failure, bool>> createCartProduct(String productId);
  Future<Either<Failure, List<ProductEntity>>> getCartProducts();
}
