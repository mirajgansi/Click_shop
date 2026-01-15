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
  Future<AuthHiveModel?> deleteUser(String userId);
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);

  Future<AuthHiveModel> login({
    required String email,
    required String password,
  });

  Future<AuthHiveModel> getUserById(String userId);

  Future<AuthHiveModel> updateUser(AuthHiveModel user);

  Future<bool> deleteUser(String userId);
}
