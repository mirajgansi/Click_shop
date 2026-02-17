import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/cart/data/model/cart_hive_model.dart';
import 'package:click_shop/features/order/data/model/order_hive_model.dart';
import 'package:click_shop/features/order/data/model/order_item_hive_model.dart';
import 'package:click_shop/features/driver/data/model/shipping_address_hive_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
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

  static const String _recentIdsBox = "recent_ids_box";
  static const String _popularIdsBox = "popular_ids_box";
  static const String _trendingIdsBox = "trending_ids_box";
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
    if (!Hive.isAdapterRegistered(HiveTableConstants.orderItemTypeId)) {
      Hive.registerAdapter(OrderItemHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.shippingAddressTypeId)) {
      Hive.registerAdapter(ShippingAddressHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstants.orderTypeId)) {
      Hive.registerAdapter(OrderHiveModelAdapter());
    }
  }

  Future<void> openBoxed() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);

    try {
      await Hive.openBox<ProductHiveModel>(HiveTableConstants.productTable);
    } catch (e) {
      await Hive.deleteBoxFromDisk(HiveTableConstants.productTable);
      await Hive.openBox<ProductHiveModel>(HiveTableConstants.productTable);
    }

    await Hive.openBox<CartHiveModel>(HiveTableConstants.cartTable);
    await Hive.openBox<OrderHiveModel>(_driverOrdersBox);
    await Hive.openBox<String>(_recentIdsBox);
    await Hive.openBox<String>(_popularIdsBox);
    await Hive.openBox<String>(_trendingIdsBox);
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

  Future<AuthHiveModel?> updateUser(AuthHiveModel model) async {
    final key = model.userId;
    if (key == null || key.isEmpty) return null;

    final exists = _authBox.containsKey(key);
    if (!exists) return null;

    await _authBox.put(key, model);
    return model;
  }

  Future<bool> deleteUser(String userId) async {
    final exists = _authBox.containsKey(userId);
    if (!exists) return false;

    await _authBox.delete(userId);
    return true;
  }

  // clear all users (optional)
  Future<void> clearUsers() async {
    await _authBox.clear();
  }

  Future<void> saveUser(AuthHiveModel user) async {
    final key = user.userId;
    if (key == null || key.isEmpty) {
      throw Exception("UserId is required to save user locally");
    }
    await _authBox.put(key, user);
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

  Box<String> get _recentBox => Hive.box<String>(_recentIdsBox);
  Box<String> get _popularBox => Hive.box<String>(_popularIdsBox);
  Box<String> get _trendingBox => Hive.box<String>(_trendingIdsBox);

  Future<void> cacheRecentIds(List<String> ids) async {
    await _recentBox.clear();
    for (final id in ids) {
      await _recentBox.add(id);
    }
  }

  Future<void> cachePopularIds(List<String> ids) async {
    await _popularBox.clear();
    for (final id in ids) {
      await _popularBox.add(id);
    }
  }

  Future<void> cacheTrendingIds(List<String> ids) async {
    await _trendingBox.clear();
    for (final id in ids) {
      await _trendingBox.add(id);
    }
  }

  Future<List<ProductHiveModel>> getRecentFromCache() async {
    final ids = _recentBox.values.toList();
    return ids
        .map((id) => _productBox.get(id))
        .whereType<ProductHiveModel>()
        .toList();
  }

  Future<List<ProductHiveModel>> getPopularFromCache() async {
    final ids = _popularBox.values.toList();
    return ids
        .map((id) => _productBox.get(id))
        .whereType<ProductHiveModel>()
        .toList();
  }

  Future<List<ProductHiveModel>> getTrendingFromCache() async {
    final ids = _trendingBox.values.toList();
    return ids
        .map((id) => _productBox.get(id))
        .whereType<ProductHiveModel>()
        .toList();
  }

  // ==================== CART ====================
  Box<CartHiveModel> get _cartBox =>
      Hive.box<CartHiveModel>(HiveTableConstants.cartTable);

  Future<bool> addToCart({required String productId, int quantity = 1}) async {
    try {
      if (productId.isEmpty) return false;
      if (quantity <= 0) quantity = 1;

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
    } catch (e) {
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
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCartProductIds() async {
    try {
      return _cartBox.values.map((e) => e.productId).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
  }

  Future<void> cacheAllProdcuts(List<ProductHiveModel> products) async {
    for (final p in products) {
      final id = p.id;
      if (id != null && id.isNotEmpty) {
        await _productBox.put(id, p);
      }
    }
  }

  Future<void> updateCartQty({
    required String productId,
    required int quantity,
  }) async {
    final box = await Hive.openBox<CartHiveModel>(HiveTableConstants.cartTable);

    final item = box.values.firstWhere(
      (e) => e.productId == productId,
      orElse: () => throw Exception("Cart item not found"),
    );

    final updated = CartHiveModel(
      productId: item.productId,
      quantity: quantity,
      cartItemId: item.cartItemId,
    );

    await box.put(item.key, updated);
  }

  static const String _driverOrdersBox = "driver_orders";

  Box<OrderHiveModel> get _driverOrderBox =>
      Hive.box<OrderHiveModel>(_driverOrdersBox);

  Future<void> cacheDriverOrders(List<OrderHiveModel> orders) async {
    await _driverOrderBox.clear();
    for (final o in orders) {
      await _driverOrderBox.put(o.id, o);
    }
  }

  List<OrderHiveModel> getDriverOrders() {
    return _driverOrderBox.values.toList();
  }

  Future<void> clearDriverOrders() async {
    await _driverOrderBox.clear();
  }
}
