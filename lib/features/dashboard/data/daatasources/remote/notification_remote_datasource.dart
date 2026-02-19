import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/dashboard/data/daatasources/notification_datasource.dart';
import 'package:click_shop/features/dashboard/data/model/notification_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRemoteDataSourceProvider =
    Provider<INotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(
        apiClient: ref.read(apiClientProvider),
        tokenService: ref.read(tokenServiceProvider),
      );
    });

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  NotificationRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Options _authOptions() {
    final token = _tokenService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<NotificationApiModel>> getMyNotifications() async {
    final response = await _apiClient.get(
      ApiEndpoints.myNotifications(),
      options: _authOptions(),
    );

    if (response.data['success'] == true) {
      final raw = response.data['items'];

      final list = (raw as List? ?? [])
          .map((e) => NotificationApiModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return list;
    }

    throw Exception(
      response.data['message'] ?? "Failed to fetch notifications",
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      ApiEndpoints.notificationUnreadCount(),
      options: _authOptions(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];

      // backend might return {count: 3} OR just 3
      if (data is Map<String, dynamic> && data['count'] != null) {
        return (data['count'] as num).toInt();
      }
      if (data is num) return data.toInt();

      // fallback
      return 0;
    }

    throw Exception(response.data['message'] ?? "Failed to fetch unread count");
  }

  @override
  Future<bool> markNotificationRead(String id) async {
    if (id.isEmpty) return false;

    final response = await _apiClient.patch(
      ApiEndpoints.markNotificationRead(id), // "notifications/:id/read"
      data: {}, // keep empty body
      options: _authOptions(),
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(response.data['message'] ?? "Failed to mark as read");
  }

  @override
  Future<bool> markAllNotificationsRead() async {
    final response = await _apiClient.patch(
      ApiEndpoints.markAllNotificationsRead(), // "notifications/me/read-all"
      data: {},
      options: _authOptions(),
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(response.data['message'] ?? "Failed to mark all as read");
  }

  @override
  Future<bool> createNotification(NotificationApiModel notification) async {
    final response = await _apiClient.post(
      ApiEndpoints.createNotification(), // "notifications"
      data: notification.toJson(),
      options: _authOptions(), // admin token required
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(
      response.data['message'] ?? "Failed to create notification",
    );
  }
}
