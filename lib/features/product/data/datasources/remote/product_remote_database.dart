import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ProductRemoteDatabaseProvider = Provider<IProductRemoteDatabase>((ref) {
  return ProductRemoteDatabase(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProductRemoteDatabase implements IProductRemoteDatabase {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProductRemoteDatabase({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<List<ProductEntity>> getAllproduct() async {
    final res = await _apiClient.get(ApiEndpoints.products);

    final data = res.data['data'];
    if (data is! List) return [];

    final models = data
        .map((json) => ProductApiModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    final res = await _apiClient.get(ApiEndpoints.getProductById(productId));

    final json = res.data['data'] as Map<String, dynamic>;
    final model = ProductApiModel.fromJson(json);

    return model.toEntity();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    // If your backend has route: /products/category/:category
    // use that. Otherwise keep queryParameters.
    final res = await _apiClient.get(
      ApiEndpoints.getByCategory(categoryId),
      // OR:
      // ApiEndpoints.Products,
      // queryParameters: {'category': categoryId},
    );

    final data = res.data['data'];
    if (data is! List) return [];

    final models = data
        .map((json) => ProductApiModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return models.map((m) => m.toEntity()).toList();
  }

  // ---------------- CART ----------------

  @override
  Future<bool> createCartProduct(String productId) async {
    try {
      final token = _tokenService.getToken();

      // Update endpoint to match your backend:
      // example: POST /api/cart/:productId  or POST /api/cart {productId}
      await _apiClient.post(
        ApiEndpoints.CartAdd, // <-- create this
        data: {'productId': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<ProductEntity>> getCartProducts() async {
    try {
      final token = _tokenService.getToken();

      // Update endpoint to match your backend:
      // example: GET /api/cart
      final res = await _apiClient.get(
        ApiEndpoints.CartGet, // <-- create this
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = res.data['data'];
      if (data is! List) return [];

      // If backend returns cart items with nested product: { product: {...} }
      // adjust this mapping accordingly.
      final models = data
          .map((json) => ProductApiModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProductEntity> getProductbyId(String productId) {
    // TODO: implement getProductbyId
    throw UnimplementedError();
  }
}
