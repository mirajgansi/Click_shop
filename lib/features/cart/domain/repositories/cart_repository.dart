import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ICartRepository {
  // cart
  Future<Either<Failure, bool>> createCartProduct(
    String productId,
    int quantity,
  );
  Future<Either<Failure, List<ProductEntity>>> getCartProducts();
  Future<Either<Failure, bool>> deleteCartItem(String cartItemId);
  Future<Either<Failure, bool>> clearCart();
  Future<Either<Failure, bool>> createOrderFromCart();
  Future<Either<Failure, bool>> cancelMyOrder(String orderId);
}
