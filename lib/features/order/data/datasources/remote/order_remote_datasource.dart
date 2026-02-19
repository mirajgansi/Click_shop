import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/order/data/datasources/order_datasource.dart';
import 'package:click_shop/features/order/data/model/order_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRemoteDatasourceProvider = Provider<IOrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class OrderRemoteDatasource implements IOrderRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  OrderRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  /// 🔐 Auth header (same as cart)
  Future<Options> _authOptions() async {
    final token = _tokenService.getToken();
    return Options(
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  // ==================== GET MY ORDERS ====================
  @override
  Future<List<OrderApiModel>> getMyOrders() async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.myOrders, // e.g. GET /orders/my
        options: await _authOptions(),
      );

      final body = res.data;
      final list = (body is Map && body["data"] is List)
          ? body["data"] as List
          : [];

      return list
          .map<OrderApiModel>(
            (e) => OrderApiModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      print("getMyOrders error: $e");
      return [];
    }
  }

  // ==================== GET ORDER BY ID ====================
  @override
  Future<OrderApiModel> getOrderById(String orderId) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.orderById(orderId), // e.g. GET /orders/:id
        options: await _authOptions(),
      );

      final body = res.data;
      final data = body is Map ? body["data"] : null;

      return OrderApiModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      print("getOrderById error: $e");
      rethrow;
    }
  }

  // ==================== CANCEL ORDER ====================
  @override
  Future<bool> cancelMyOrder(String orderId) async {
    try {
      final res = await _apiClient.put(
        ApiEndpoints.cancelOrder(orderId),
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;

      return true;
    } catch (e) {
      print("cancelOrder error: $e");
      return false;
    }
  }

  @override
  Future<bool> createOrderFromCart(Map<String, dynamic> shippingJson) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.createOrder, // see endpoint note below
        data: {"shippingAddress": shippingJson},
        options: await _authOptions(),
      );

      final data = res.data;
      if (data is Map && data["success"] == false) return false;
      return true;
    } catch (e) {
      print("createOrderFromCart error: $e");
      return false;
    }
  }

  @override
  Future<List<OrderApiModel>> getDriverOrders() {
    // TODO: implement getDriverOrders
    throw UnimplementedError();
  }
}
