import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/driver/data/datasources/driver_datasource.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final driverRemoteDataSourceProvider = Provider<IDriverRemoteDatabase>((ref) {
  return DriverRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(UserSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class DriverRemoteDatasource implements IDriverRemoteDatabase {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  DriverRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<List<OrderEntity>> getMyAssignedOrders() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverMyOrders,
      options: Options(
        headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'},
      ),
    );

    if (response.data['success'] == true) {
      final body = response.data as Map<String, dynamic>;

      final List list = (body['orders'] as List? ?? []); // ✅ FIX HERE

      return list
          .map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(response.data['message'] ?? "Failed to load driver orders");
  }

  @override
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.driverUpdateOrderStatus(orderId),
      data: {"status": status},
      options: Options(
        headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'},
      ),
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(
      response.data['message'] ?? "Failed to update order status",
    );
  }
}
