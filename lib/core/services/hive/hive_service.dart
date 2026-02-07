import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/cart/data/model/cart_hive_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final HiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);

    _registerAdapter();
    await openBoxed();
  }

  void _registerAdapter() {
    // Auth adapter
    if (!Hive.isAdapterRegistered(HiveTableConstants.authtypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstants.productTypeId)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.cartTypeId)) {
      Hive.registerAdapter(CartHiveModelAdapter());
    }
  }

  Future<void> openBoxed() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);

    await Hive.openBox<ProductHiveModel>(HiveTableConstants.productTable);

    await Hive.openBox<String>(HiveTableConstants.cartTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // ==================== AUTH ====================
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) return users.first;
    return null;
  }

  Future<void> logoutUser() async {}

  AuthHiveModel? getCurrentUser(String userId) {
    return _authBox.get(userId);
  }

  Future<void> cacheUser(List<AuthHiveModel> userId) async {
    await _authBox.clear();
    for (var auth in userId) {
      await _authBox.put(auth.userId, auth);
    }
  }

  bool isEmailExists(String email) {
    final users = _authBox.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
    return users.isNotEmpty;
  }

  // ==================== PRODUCTS ====================
  Box<ProductHiveModel> get _productBox =>
      Hive.box<ProductHiveModel>(HiveTableConstants.productTable);

  Future<ProductHiveModel> createProduct(ProductHiveModel model) async {
    final key = model.id;
    if (key == null || key.isEmpty) {
      throw Exception("Product id (_id) is required to save locally");
    }
    await _productBox.put(key, model);
    return model;
  }

  Future<List<ProductHiveModel>> getAllProducts() async {
    return _productBox.values.toList();
  }

  Future<ProductHiveModel?> getProductById(String id) async {
    return _productBox.get(id);
  }

  Future<bool> updateProduct(ProductHiveModel model) async {
    final key = model.id;
    if (key == null || key.isEmpty) return false;

    final exists = _productBox.containsKey(key);
    if (!exists) return false;

    await _productBox.put(key, model);
    return true;
  }

  Future<bool> deleteProduct(String productId) async {
    final exists = _productBox.containsKey(productId);
    if (!exists) return false;

    await _productBox.delete(productId);
    return true;
  }

  // ==================== CART ====================
  Box<CartHiveModel> get _cartBox =>
      Hive.box<CartHiveModel>(HiveTableConstants.cartTable);

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
    required,
  }) async {
    try {
      if (productId.isEmpty) return false;
      if (quantity <= 0) quantity = 1;

      // ✅ Use productId as the KEY so updates are easy
      final existing = _cartBox.get(productId);

      if (existing != null) {
        final updated = CartHiveModel(
          cartItemId: existing.cartItemId,
          productId: existing.productId,
          quantity: existing.quantity + quantity,
        );
        await _cartBox.put(productId, updated);
      } else {
        final item = CartHiveModel(
          productId: productId,
          quantity: quantity,
          cartItemId: "",
        );
        await _cartBox.put(productId, item);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCartQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      final existing = _cartBox.get(productId);
      if (existing == null) return false;

      if (quantity <= 0) {
        await _cartBox.delete(productId); // remove item if qty <= 0
        return true;
      }

      final updated = CartHiveModel(
        cartItemId: existing.cartItemId,
        productId: existing.productId,
        quantity: quantity,
      );

      await _cartBox.put(productId, updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    try {
      if (!_cartBox.containsKey(productId)) return false;
      await _cartBox.delete(productId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isInCart(String productId) async {
    try {
      return _cartBox.containsKey(productId);
    } catch (_) {
      return false;
    }
  }

  Future<List<CartHiveModel>> getAllCart() async {
    try {
      return _cartBox.values.toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getCartProductIds() async {
    try {
      return _cartBox.values.map((e) => e.productId).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
  }

  Future<void> cacheAllProdcuts(List<ProductHiveModel> products) async {
    await _productBox.clear();
    for (var product in products) {
      await _productBox.put(product.id, product);
    }
  }
}
