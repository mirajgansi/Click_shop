import 'dart:core';

import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';

/// LOCAL (Hive) DB
abstract interface class IProductLocalDatabase {
  Future<List<ProductHiveModel>> getAllproduct();
  Future<ProductHiveModel?> getProductbyId(String productId);
  Future<List<ProductHiveModel>> getProductsByCategory(String category);

  Future<List<ProductHiveModel>> getRecent();
  Future<List<ProductHiveModel>> getTrending();
  Future<List<ProductHiveModel>> getPopular();
  Future<List<ProductHiveModel>> getTopRated();
  Future<List<ProductHiveModel>> getOutOfStock();
  Future<void> cacheAll(List<ProductHiveModel> items);
  Future<void> cacheCategory(String category, List<ProductHiveModel> items);
  Future<void> cacheRecent(List<ProductHiveModel> items);
  Future<void> cacheTrending(List<ProductHiveModel> items);
  Future<void> cachePopular(List<ProductHiveModel> items);
  Future<void> cacheTopRated(List<ProductHiveModel> items);
  Future<void> cacheOutOfStock(List<ProductHiveModel> items);
  Future<void> upsertProduct(ProductHiveModel product);
  Future<List<ProductHiveModel>> getMyFavoritesFromCache(String userId);
  Future<List<String>> getProductCommentsFromCache(String productId);
}

abstract interface class IProductRemoteDatabase {
  Future<List<ProductApiModel>> getAllproduct({
    int page = 1,
    int size = 20,
    String? search,
  });

  Future<ProductApiModel?> getProductbyId(String productId);
  Future<List<ProductApiModel>> getProductsByCategory(String category);
  Future<List<ProductApiModel>> getRecent();
  Future<List<ProductApiModel>> getTrending();
  Future<List<ProductApiModel>> getPopular();
  Future<List<ProductApiModel>> getTopRated();
  Future<List<ProductApiModel>> getOutOfStock();
  Future<void> incrementViewCount(String productId);

  Future<ProductApiModel> rateProduct({
    required String productId,
    required double rating,
  });

  Future<ProductApiModel> toggleFavorite({required String productId});

  Future<ProductApiModel> addComment({
    required String productId,
    required String comment,
  });

  Future<List<ProductApiModel>> getMyFavorites();

  Future<List<CommentApiModel>> getProductComments({required String productId});
}
