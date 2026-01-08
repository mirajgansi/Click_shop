import 'dart:core';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IProductDatabase {
  Future<bool> createProduct(ProductEntity productEntity);
  Future<ProductEntity> getAllproduct();
  Future<ProductEntity> getProductbyId(String productId);
  Future<bool> deleteProduct(String productId);
  Future<bool> updateProduct(ProductEntity productEntity);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
  Future<List<ProductEntity>> searchProducts(String query);
  Future<bool> favoriteProduct(String productId);
  Future<List<ProductEntity>> getFavoriteProducts();
}
