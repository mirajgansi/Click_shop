import 'package:click_shop/core/services/hive_service.dart';
import 'package:click_shop/features/product/data/datasources/remote/product_database.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ProductDatasourceProvider = Provider<IProductDatabase>((ref) {
  final hiveService = ref.watch(HiveServiceProvider);
  return ProdcutLocalDatabase(hiveService: hiveService);
});

class ProdcutLocalDatabase implements IProductDatabase {
  final HiveService _hiveService;
  ProdcutLocalDatabase({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> createProduct(ProductEntity productEntity) {
    // TODO: implement createProduct
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteProduct(String productId) {
    // TODO: implement delteProduct
    throw UnimplementedError();
  }

  @override
  Future<bool> favoriteProduct(String productId) {
    // TODO: implement favoriteProduct
    throw UnimplementedError();
  }

  @override
  Future<ProductEntity> getAllproduct() {
    // TODO: implement getAllproduct
    throw UnimplementedError();
  }

  @override
  Future<List<ProductEntity>> getFavoriteProducts() {
    // TODO: implement getFavoriteProducts
    throw UnimplementedError();
  }

  @override
  Future<ProductEntity> getProductbyId(String productId) {
    // TODO: implement getProductbyId
    throw UnimplementedError();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) {
    // TODO: implement getProductsByCategory
    throw UnimplementedError();
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) {
    // TODO: implement searchProducts
    throw UnimplementedError();
  }

  @override
  Future<bool> updateProduct(ProductEntity productEntity) {
    // TODO: implement updateProduct
    throw UnimplementedError();
  }
}
