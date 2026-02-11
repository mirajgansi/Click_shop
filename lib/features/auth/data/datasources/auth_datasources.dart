import 'dart:io';

import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';

// abstract interface class IAuthDatasource {
//   Future<AuthHiveModel> register(AuthHiveModel user);
//   Future<AuthHiveModel?> login(String email, String password);
//   Future<AuthHiveModel?> getCurrentUser();
//   Future<bool> logout();
//   Future<bool> isEmailExists(String email);
// }

//use this for future
abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserbyId(String userId);
  Future<AuthHiveModel?> getUserbyEmail(String email);
  Future<AuthHiveModel?> updateUser(AuthHiveModel user);
  Future<void> clearUser();
  Future<void> saveUser(AuthHiveModel user);
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel> whoAmI();
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel> getUserById(String userId);
  Future<AuthApiModel> updateProfileImage(File image);
  Future<AuthApiModel> updateUser(AuthEntity user);
  Future<bool> deleteMe(String password);

  /// POST /auth/request-password-reset
  Future<bool> requestPasswordReset(String email);

  /// POST /auth/reset-password/:token
  /// POST /auth/reset-password
  Future<bool> resetPassword({
    required String email,
    required String code, // keep String (important!)
    required String newPassword,
  });
}
