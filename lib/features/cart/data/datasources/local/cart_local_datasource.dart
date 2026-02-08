import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/features/cart/data/datasources/cart_datasource.dart';
import 'package:click_shop/features/cart/data/model/cart_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartLocalDatasourceProvider = Provider<CartLocalDatasource>((ref) {
  final hiveService = ref.read(HiveServiceProvider);
  return CartLocalDatasource(hiveService: hiveService);
});

class CartLocalDatasource implements ICartLocalDatabase {
  final HiveService _hiveService;

  CartLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> createCartProduct(String productId, int quantity) async {
    try {
      await _hiveService.addToCart(productId: productId, quantity: quantity);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CartHiveModel>> getCartProducts() async {
    try {
      return _hiveService.getAllCart();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> deleteCartItem(String cartItemId) async {
    try {
      await _hiveService.removeFromCart(cartItemId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearCart() async {
    try {
      await _hiveService.clearCart();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateCartQty({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _hiveService.updateCartQty(
        productId: productId,
        quantity: quantity,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
