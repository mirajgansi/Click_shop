import 'dart:io';

import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';

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
  Future<AuthHiveModel?> updateUser(String user);
  Future<void> clearUser();
  Future<void> saveUser(AuthHiveModel user);
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel> WhoAmI();
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel> getUserById(String userId);
  Future<AuthApiModel> updateProfileImage(File image);
  Future<AuthHiveModel?> updateUser(String user);
  Future<bool> deleteMe();

  /// POST /auth/request-password-reset
  Future<bool> requestPasswordReset(String email);

  /// POST /auth/reset-password/:token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  });
}
