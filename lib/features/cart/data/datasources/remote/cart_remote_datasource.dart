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
    final token = await _tokenService.getToken();
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
        ApiEndpoints.cartGet(), // "cart/item"
        options: await _authOptions(),
      );

      // ✅ Handle common response shapes:
      // 1) {data: [...]}
      // 2) {data: {items:[...]}}
      final body = res.data;

      dynamic list = body;
      if (body is Map && body["data"] != null) list = body["data"];
      if (list is Map && list["items"] != null) list = list["items"];

      if (list is! List) return [];

      return list.map<ProductApiModel>((item) {
        final map = item as Map<String, dynamic>;
        final productJson = map["product"] is Map ? map["product"] : map;
        return ProductApiModel.fromJson(Map<String, dynamic>.from(productJson));
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print("getCartProducts error: $e");
      return [];
    }
  }

  @override
  Future<bool> deleteCartItem(String cartItemId) async {
    try {
      final res = await _apiClient.delete(
        ApiEndpoints.deleteCart(cartItemId), // "cart/item/:id"
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;

      return true;
    } catch (e) {
      // ignore: avoid_print
      print("deleteCartItem error: $e");
      return false;
    }
  }

  @override
  Future<bool> clearCart() async {
    try {
      final res = await _apiClient.delete(
        ApiEndpoints.deleteAllCart(), // "cart"
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;

      return true;
    } catch (e) {
      // ignore: avoid_print
      print("clearCart error: $e");
      return false;
    }
  }
}
