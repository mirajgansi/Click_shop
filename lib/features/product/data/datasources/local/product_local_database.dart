import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
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
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProductHiveModel?> getProductbyId(String productId) async {
    try {
      return await _hiveService.getProductById(productId);
    } catch (_) {
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
    } catch (_) {
      return [];
    }
  }

  // ---------------- CACHING HELPERS ----------------

  @override
  Future<void> cacheAll(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (_) {}
  }

  @override
  Future<void> cacheCategory(
    String categoryId,
    List<ProductHiveModel> items,
  ) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
    } catch (_) {}
  }

  @override
  Future<void> cacheRecent(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
      final ids = items
          .map((e) => e.id)
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
      await _hiveService.cacheRecentIds(ids);
    } catch (_) {}
  }

  @override
  Future<void> cacheTrending(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
      final ids = items
          .map((e) => e.id)
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
      await _hiveService.cacheTrendingIds(ids);
    } catch (_) {}
  }

  @override
  Future<void> cachePopular(List<ProductHiveModel> items) async {
    try {
      await _hiveService.cacheAllProdcuts(items);
      final ids = items
          .map((e) => e.id)
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
      await _hiveService.cachePopularIds(ids);
    } catch (_) {}
  }

  // ✅ implement top-rated cache same style
  @override
  Future<void> cacheTopRated(List<ProductHiveModel> items) async {
    try {
      // easiest: just cache products (optional: make a topRatedIdsBox like others)
      await _hiveService.cacheAllProdcuts(items);
    } catch (_) {}
  }

  // ✅ implement out-of-stock cache (simple)
  @override
  Future<void> cacheOutOfStock(List<ProductHiveModel> items) async {
    try {
      // simplest: cache products only
      await _hiveService.cacheAllProdcuts(items);
    } catch (_) {}
  }

  // ---------------- GET SECTIONS FROM CACHE ----------------

  @override
  Future<List<ProductHiveModel>> getRecent() async {
    try {
      return await _hiveService.getRecentFromCache();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getTrending() async {
    try {
      return await _hiveService.getTrendingFromCache();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getPopular() async {
    try {
      return await _hiveService.getPopularFromCache();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getTopRated() async {
    try {
      final all = await _hiveService.getAllProducts();

      all.sort((a, b) {
        final ar = a.averageRating ?? 0.0;
        final br = b.averageRating ?? 0.0;
        return br.compareTo(ar);
      });

      return all;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ProductHiveModel>> getOutOfStock() async {
    try {
      final all = await _hiveService.getAllProducts();
      return all.where((p) => p.inStock <= 0).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> upsertProduct(ProductHiveModel product) async {
    try {
      await _hiveService.updateProduct(product);
      final id = product.id;
      if (id != null && id.isNotEmpty) {
        final existing = await _hiveService.getProductById(id);
        if (existing == null) {
          await _hiveService.createProduct(product);
        }
      }
    } catch (_) {}
  }

  @override
  Future<List<ProductHiveModel>> getMyFavoritesFromCache(String userId) async {
    try {
      return await _hiveService.getMyFavoritesFromCache(userId);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> getProductCommentsFromCache(String productId) async {
    try {
      final p = await _hiveService.getProductById(productId);
      return p?.comments ?? const [];
    } catch (_) {
      return [];
    }
  }
}
