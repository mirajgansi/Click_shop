import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ProductLocalDatasourceProvider = Provider<ProdcutLocalDatabase>((ref) {
  final hiveService = ref.watch(HiveServiceProvider);
  return ProdcutLocalDatabase(hiveService: hiveService);
});

class ProdcutLocalDatabase implements IProductLocalDatabase {
  final HiveService _hiveService;

  ProdcutLocalDatabase({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<List<ProductHiveModel>> getAllproduct() async {
    try {
      return await _hiveService.getAllProducts();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ProductHiveModel?> getProductbyId(String productId) async {
    try {
      return await _hiveService.getProductById(productId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ProductHiveModel>> getProductsByCategory(
    String categoryId,
  ) async {
    try {
      final all = await getAllproduct();
      final cat = categoryId.trim().toLowerCase();

      return all.where((p) => p.category.trim().toLowerCase() == cat).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheAll(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (e) {}
  }

  @override
  Future<void> cacheCategory(
    String categoryId,
    List<ProductHiveModel> items,
  ) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (e) {}
  }

  @override
  Future<void> cacheRecent(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (e) {}
  }

  @override
  Future<void> cacheTrending(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (e) {}
  }

  @override
  Future<void> cachePopular(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (e) {}
  }

  @override
  Future<void> cacheTopRated(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (e) {}
  }

  @override
  Future<List<ProductHiveModel>> getRecent() async {
    try {
      return await getAllproduct();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getTrending() async {
    try {
      return await getAllproduct();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getPopular() async {
    try {
      return await getAllproduct();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getTopRated() async {
    try {
      return await getAllproduct();
    } catch (e) {
      return [];
    }
  }
}
