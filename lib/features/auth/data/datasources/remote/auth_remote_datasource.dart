import 'dart:io';

import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//create Provider
final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(UserSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
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
  Future<AuthApiModel> updateProfileImage(File image) async {
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final token = _tokenService.getToken();

    final response = await _apiClient.put(
      ApiEndpoints.userPhoto(_userSessionService.getCurrentUserId()!),
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        contentType: "multipart/form-data",
      ),
    );

    if (response.data["success"] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    throw Exception("Failed to update profile image");
  }

  // @override
  // Future<AuthApiModel> video(AuthApiModel user, File image) async {
  //   final fileName = video.path.split('/').last;
  //   final formData = FormData.fromMap({
  //     'itemVideo': MultipartFile.fromFile(video.path, filename: fileName),
  //   });
  //   //get token
  //   final token = _tokenService.getToken();
  //   final respone = await _apiClient.uploadFile(
  //     ApiEndpoints.userBVideo(user.userId!), // j ni huna sakxa yeta backend anusart
  //     formData: formData,
  //     options: Options(headers: {'Authorization': 'Bearer  $token'}),
  //   );
  //   return respone.data['success'];

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final body = response.data as Map<String, dynamic>;

      final data = body['data'] as Map<String, dynamic>;

      final user = AuthApiModel.fromJson(data);

      if (user.userId == null || user.userId!.isEmpty) {
        throw Exception("Missing userId. data=$data");
      }

      await _userSessionService.saveUserSession(
        userId: user.userId!,
        email: user.email,
        username: user.username,
      );
      //save token

      final token = response.data['token'] as String?;
      await _tokenService.saveToken(token!);
      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> whoAmI() async {
    final response = await _apiClient.get(
      ApiEndpoints.whoAmI,
      options: Options(
        headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'},
      ),
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

  @override
  Future<AuthApiModel> updateUser(AuthEntity user) async {
    final apiModel = AuthApiModel.formEnitity(user);
    final data = apiModel.toProfileUpdateJson(); // removes password/nulls

    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: data,
      options: Options(
        headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'},
      ),
    );

    if (response.data['success'] == true) {
      return AuthApiModel.fromJson(response.data['data']);
    }

    throw Exception(response.data['message'] ?? "Update failed");
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestPasswordReset, // auth/request-password-reset
      data: {"email": email},
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(
      response.data['message'] ?? "Failed to request password reset",
    );
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {"email": email, "code": code, "newPassword": newPassword},
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(response.data['message'] ?? "Failed to reset password");
  }

  @override
  Future<bool> deleteMe(String password) async {
    final response = await _apiClient.delete(
      ApiEndpoints.deleteMe, // auth/me
      data: {"password": password},

      options: Options(
        headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'},
      ),
    );

    if (response.data['success'] == true) {
      return true;
    }

    throw Exception(response.data['message'] ?? "Failed to delete user");
  }

  @override
  Future<bool> saveFcmToken(String token) async {
    print("🔥 REMOTE saveFcmToken() HIT. token=${token.substring(0, 10)}...");
    print("🔥 JWT used = ${_tokenService.getToken()?.substring(0, 20)}...");

    final res = await _apiClient.post(
      ApiEndpoints.saveFcmToken,
      data: {"token": token},
      options: Options(
        headers: {'Authorization': 'Bearer ${_tokenService.getToken()}'},
      ),
    );

    print("🔥 REMOTE saveFcmToken() RESPONSE: ${res.statusCode} ${res.data}");
    return res.data["success"] == true;
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.verifyResetCode,
      data: {"email": email, "code": code},
    );

    print("🔥 verifyResetCode RESPONSE: ${res.statusCode} ${res.data}");

    return res.data["success"] == true;
  }
}
