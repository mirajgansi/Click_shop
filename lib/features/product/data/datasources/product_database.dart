import 'dart:core';

import 'package:click_shop/features/product/domain/entities/product_entity.dart';

abstract interface class IProductLocalDatabase {
  Future<List<ProductEntity>> getAllproduct();
  Future<ProductEntity> getProductbyId(String productId);
  // Future<bool> deleteProduct(String productId);
  // Future<bool> updateProduct(ProductEntity productEntity);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
  // Future<List<ProductEntity>> searchProducts(String query);
  Future<bool> createCartProduct(String productId);
  Future<List<ProductEntity>> getCartProducts();
}

abstract interface class IProductRemoteDatabase {
  // Future<bool> createProduct(ProductEntity productEntity);
  Future<List<ProductEntity>> getAllproduct();
  Future<ProductEntity> getProductbyId(String productId);
  // Future<bool> deleteProduct(String productId);
  // Future<bool> updateProduct(ProductEntity productEntity);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
  // Future<List<ProductEntity>> searchProducts(String query);
  Future<bool> createCartProduct(String productId);
  Future<List<ProductEntity>> getCartProducts();
}
