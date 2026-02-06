import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
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
  Future<List<ProductEntity>> getAllproduct() async {
    final products = await _hiveService.getAllProducts();
    return products.map((p) => p.toEntity()).toList();
  }

  @override
  Future<ProductEntity> getProductbyId(String productId) async {
    final ProductHiveModel? model = await _hiveService.getProductById(
      productId,
    );
    if (model == null) {
      throw Exception("Product not found in local database");
    }
    return model.toEntity();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    try {
      final all = await getAllproduct();
      final cat = categoryId.trim().toLowerCase();
      return all.where((p) => p.category.trim().toLowerCase() == cat).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------- CART ----------------

  @override
  Future<bool> createCartProduct(String productId) async {
    try {
      await _hiveService.addToCart(productId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ProductEntity>> getCartProducts() async {
    try {
      final cartIds = await _hiveService.getCartProductIds(); // ✅ await here
      if (cartIds.isEmpty) return [];

      // Fetch all products once (faster than get by id in a loop)
      final allModels = await _hiveService.getAllProducts();
      final mapById = {
        for (final m in allModels)
          if (m.id != null) m.id!: m,
      };

      final result = <ProductEntity>[];
      for (final id in cartIds) {
        final model = mapById[id];
        if (model != null) result.add(model.toEntity());
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  // Future<void> cacheAllItems(List<ProductHiveModel> items) async {
  //   await _hiveService.cacheAllItems(items);
  // }
}
