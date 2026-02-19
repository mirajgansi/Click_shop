import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/cart/data/datasources/cart_datasource.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartRemoteDatasourceProvider = Provider<ICartRemoteDatabase>((ref) {
  return CartRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class CartRemoteDatasource implements ICartRemoteDatabase {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  CartRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Future<Options> _authOptions() async {
    final token = _tokenService.getToken();
    return Options(
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  @override
  Future<bool> createCartProduct(String productId, int quantity) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.cartAdd(), // "cart"
        data: {
          "productId": productId,
          "quantity": quantity, // ✅ use param
        },
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;

      return true;
    } catch (e) {
      // ignore: avoid_print
      print("createCartProduct error: $e");
      return false;
    }
  }

  @override
  Future<List<ProductApiModel>> getCartProducts() async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.cartGet(),
        options: await _authOptions(),
      );

      final body = res.data;

      final items =
          (body is Map && body["data"] is Map && body["data"]["items"] is List)
          ? body["data"]["items"] as List
          : <dynamic>[];

      return items.map<ProductApiModel>((item) {
        final itemMap = Map<String, dynamic>.from(item as Map);

        // product details
        final productJson = Map<String, dynamic>.from(
          itemMap["productId"] as Map,
        );

        // ✅ IMPORTANT: attach quantity
        productJson["quantity"] = itemMap["quantity"];

        return ProductApiModel.fromJson(productJson);
      }).toList();
    } catch (e) {
      print("getCartProducts error: $e");
      return [];
    }
  }

  @override
  Future<bool> deleteCartItem(String productId) async {
    try {
      final res = await _apiClient.delete(
        ApiEndpoints.deleteCartItem(productId),
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;
      return true;
    } catch (e) {
      print("deleteCartItem error: $e");
      return false;
    }
  }

  @override
  Future<bool> clearCart() async {
    try {
      final res = await _apiClient.delete(
        ApiEndpoints.clearCart(),
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;
      return true;
    } catch (e) {
      print("clearCart error: $e");
      return false;
    }
  }

  @override
  Future<bool> updateCartQty({
    required String productId,
    required int quantity,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.updateCartQty(productId),
      data: {"quantity": quantity},
      options: await _authOptions(),
    );
    return res.statusCode == 200;
  }
}
