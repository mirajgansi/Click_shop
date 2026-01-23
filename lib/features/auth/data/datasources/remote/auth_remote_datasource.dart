import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//create Provider
final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(UserSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return user;
  }

  @override
  Future<AuthApiModel> updateUser(AuthApiModel user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteUser(String userId) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final body = response.data as Map<String, dynamic>;

      final data = body['data'] as Map<String, dynamic>;
      final token = body['token']?.toString();

      final user = AuthApiModel.fromJson(data);

      if (user.userId == null || user.userId!.isEmpty) {
        throw Exception("Missing userId. data=$data");
      }
      if (token == null || token.isEmpty) {
        throw Exception("Missing token. body=$body");
      }

      await _userSessionService.saveUserSession(
        userId: user.userId!,
        email: user.email,
        username: user.username,

        token: token,
      );

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> WhoAmI() async {
    final token = _userSessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }

    final response = await _apiClient.get(
      ApiEndpoints.whoAmI,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    throw Exception("Failed to fetch user info");
  }

  @override
  Future<AuthApiModel> getUserById(String userId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}
