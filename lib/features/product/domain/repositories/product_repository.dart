import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IProductRepository {
  // admin (if used in your app)
  Future<Either<Failure, bool>> createProduct(ProductEntity productEntity);
  Future<Either<Failure, bool>> updateProduct(ProductEntity productEntity);
  Future<Either<Failure, bool>> delteProduct(String productId);

  // public
  Future<Either<Failure, List<ProductEntity>>> getAllproduct();
  Future<Either<Failure, ProductEntity>> getProductbyId(String productId);

  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category, // was categoryId
  );

  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int page,
    int size,
  });

  Future<Either<Failure, List<ProductEntity>>> getRecentProducts();
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts();
  Future<Either<Failure, List<ProductEntity>>> getPopularProducts();
  Future<Either<Failure, List<ProductEntity>>> getTopRatedProducts();
  Future<Either<Failure, List<ProductEntity>>> getOutOfStockProducts();
  Future<Either<Failure, bool>> incrementViewCount(String productId);
}
