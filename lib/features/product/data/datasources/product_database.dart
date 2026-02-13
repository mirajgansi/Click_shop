import 'dart:core';

import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';

abstract interface class IProductLocalDatabase {
  Future<List<ProductHiveModel>> getAllproduct();
  Future<ProductHiveModel?> getProductbyId(String productId);
  Future<List<ProductHiveModel>> getProductsByCategory(String categoryId);

  Future<List<ProductHiveModel>> getRecent();
  Future<List<ProductHiveModel>> getTrending();
  Future<List<ProductHiveModel>> getPopular();
  Future<List<ProductHiveModel>> getTopRated();

  Future<void> cacheAll(List<ProductHiveModel> items);
  Future<void> cacheCategory(String categoryId, List<ProductHiveModel> items);
  Future<void> cacheRecent(List<ProductHiveModel> items);
  Future<void> cacheTrending(List<ProductHiveModel> items);
  Future<void> cachePopular(List<ProductHiveModel> items);
  Future<void> cacheTopRated(List<ProductHiveModel> items);
}

abstract interface class IProductRemoteDatabase {
  Future<List<ProductApiModel>> getAllproduct({
    int page = 1,
    int size = 20,
    String? search,
  });
  Future<ProductApiModel?> getProductbyId(String productId);
  Future<List<ProductApiModel>> getProductsByCategory(String categoryId);

  Future<List<ProductApiModel>> getRecent();
  Future<List<ProductApiModel>> getTrending();
  Future<List<ProductApiModel>> getPopular();
  Future<List<ProductApiModel>> getTopRated();
}
