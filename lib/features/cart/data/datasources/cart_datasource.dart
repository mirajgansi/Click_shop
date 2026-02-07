import 'dart:core';

import 'package:click_shop/features/cart/data/model/cart_hive_model.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';

abstract interface class ICartLocalDatabase {
  Future<bool> createCartProduct(String productId, int quantity);
  Future<List<CartHiveModel>> getCartProducts();
  Future<bool> deleteCartItem(String cartItemId);
  Future<bool> clearCart();
}

abstract interface class ICartRemoteDatabase {
  Future<bool> createCartProduct(String productId, int quantity);
  Future<List<ProductApiModel>> getCartProducts();
  Future<bool> deleteCartItem(String cartItemId);
  Future<bool> clearCart();
}
//  Future<Either<Failure, bool>> createCartProduct(
//     String productId,
//     int quantity,
//   );
//   Future<Either<Failure, List<ProductEntity>>> getCartProducts();