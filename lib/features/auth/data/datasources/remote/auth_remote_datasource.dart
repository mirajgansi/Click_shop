import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  // final ApiClient _apiClient;
  // final
  @override
  Future<bool> deleteUser(String userId) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel> getUserById(String userId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel> login({
    required String email,
    required String password,
  }) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel> updateUser(AuthHiveModel user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
