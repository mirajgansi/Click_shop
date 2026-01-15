import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:click_shop/features/product/data/repositories/product_repository.dart';
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
    if (!Hive.isAdapterRegistered(HiveTableConstants.authtypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxed() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  }

  // Delete all batches
  // Future<void> deleteAllBatches() async {
  //   await _batchBox.clear();
  // }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ==================== Batch CRUD Operations ====================

  // Get batch box
  // Box<BatchHiveModel> get _batchBox =>
  //     Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

  // // Create a new batch
  // Future<BatchHiveModel> createBatch(BatchHiveModel batch) async {
  //   await _batchBox.put(batch.batchId, batch);
  //   return batch;
  // }

  // // Get all batches
  // List<BatchHiveModel> getAllBatches() {
  //   return _batchBox.values.toList();
  // }

  // // Get batch by ID
  // BatchHiveModel? getBatchById(String batchId) {
  //   return _batchBox.get(batchId);
  // }

  // // Update a batch
  // Future<void> updateBatch(BatchHiveModel batch) async {
  //   await _batchBox.put(batch.batchId, batch);
  // }

  // // Delete a batch
  // Future<void> deleteBatch(String batchId) async {
  //   await _batchBox.delete(batchId);
  // }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  //login user

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  //logout user
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String userId) {
    return _authBox.get(userId);
  }

  //is email exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
    return users.isNotEmpty;
  }
}

//Prodyct Box
Box<ProductHiveModel> get _productBox =>
    Hive.box<ProductHiveModel>(HiveTableConstants.productTable);

Future<ProductHiveModel> createProduct(ProductHiveModel model) async {
  await _productBox.put(model.productId, model);
  return model;
}

Future<List<ProductHiveModel>> getAllProducts() async {
  return _productBox.values.toList();
}

Future<ProductHiveModel?> getProductById(String productId) async {
  return _productBox.get(productId);
}

Future<bool> updateProduct(ProductHiveModel model) async {
  final exists = _productBox.containsKey(model.productId);
  if (!exists) return false;

  await _productBox.put(model.productId, model);
  return true;
}

Future<bool> deleteProduct(String productId) async {
  final exists = _productBox.containsKey(productId);
  if (!exists) return false;

  await _productBox.delete(productId);
  return true;
}

  // Future<List<ProductHiveModel>> getProductsByCategory(String categoryId) async {
  //   return _productBox.values
  //       .where((p) => p.categoryId == categoryId)
  //       .toList();
  // }

  // Future<List<ProductHiveModel>> searchProducts(String query) async {
  //   final q = query.trim().toLowerCase();
  //   if (q.isEmpty) return [];

  //   return _productBox.values
  //       .where((p) => p.name.toLowerCase().contains(q))
  //       .toList();
  // }

  // Future<bool> toggleFavorite(String productId) async {
  //   final product = _productBox.get(productId);
  //   if (product == null) return false;

  //   final updated = product.copyWith(isFavorite: !product.isFavorite);
  //   await _productBox.put(productId, updated);
  //   return true;
  // }

  // Future<List<ProductHiveModel>> getFavoriteProducts() async {
  //   return _productBox.values.where((p) => p.isFavorite).toList();
  // }

