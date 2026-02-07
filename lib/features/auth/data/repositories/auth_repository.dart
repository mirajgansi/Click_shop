import 'dart:io';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Provider

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.watch(AuthLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDataSourceProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.WhoAmI();
        final entity = apiModel.toEntity();

        return Right(entity);
      } catch (e) {
        return _getCachedUser();
      }
    } else {
      return _getCachedUser();
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        return left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDatasource.login(email, password);
        if (model != null) {
          return Right(model.toEntity());
        }
        return Left(LocalDatabaseFailure(message: "Login failed"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  Future<Either<Failure, AuthEntity>> _getCachedUser() async {
    try {
      final model = await _authDatasource.getCurrentUser();
      if (model == null) {
        return const Left(LocalDatabaseFailure(message: "No user found"));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Logout failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      ///remote ma jau
      try {
        final apiModel = AuthApiModel.formEnitity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registrationm Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        //check if email already exist
        final existingUser = await _authDatasource.getUserbyEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }
        final authModel = AuthHiveModel(
          email: user.email,
          username: user.username,
          password: user.password,
          // profileImage: user.profileImage,
          confirmPassword: user.confirmPassword,
        );
        await _authDatasource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> updateProfileImage(String? image) async {
    //remote mma matra image upload hunu paryo locally hudaina
    if (await _networkInfo.isConnected) {
      try {
        if (image == null) {
          return const Left(ApiFailure(message: "Image path is required"));
        }
        final updatedModel = await _authRemoteDataSource.updateProfileImage(
          File(image),
        );
        return Right(updatedModel.toEntity().toString());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Update Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        ApiFailure(message: "No internet connection. Cannot update user."),
      );
    }
  }
}
