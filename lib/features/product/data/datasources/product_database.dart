import 'dart:core';

import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';

abstract interface class IProductLocalDatabase {
  Future<List<ProductHiveModel>> getAllproduct();
  Future<ProductHiveModel?> getProductbyId(String productId);
  // Future<bool> deleteProduct(String productId);
  // Future<bool> updateProduct(ProductApiModel ProductApiModel);
  Future<List<ProductHiveModel>> getProductsByCategory(String categoryId);
  // Future<List<ProductApiModel>> searchProducts(String query);
}

abstract interface class IProductRemoteDatabase {
  // Future<bool> createProduct(ProductApiModel ProductApiModel);
  Future<List<ProductApiModel>> getAllproduct();
  Future<ProductApiModel?> getProductbyId(String productId);
  // Future<bool> deleteProduct(String productId);
  // Future<bool> updateProduct(ProductApiModel ProductApiModel);
  Future<List<ProductApiModel>> getProductsByCategory(String categoryId);
  // Future<List<ProductApiModel>> searchProducts(String query);
}
