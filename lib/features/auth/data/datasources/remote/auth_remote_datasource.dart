import 'dart:io';

import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
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
  // }

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
  Future<AuthApiModel> WhoAmI() async {
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
}
