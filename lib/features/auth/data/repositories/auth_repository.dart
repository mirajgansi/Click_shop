import 'dart:async';
import 'dart:io';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
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
  final tokenService = ref.read(tokenServiceProvider);

  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
    tokenService: tokenService,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final TokenService _tokenService;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
    required TokenService tokenService,
  }) : _authDatasource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo,
       _tokenService = tokenService;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    // 1) return cache immediately (fast)
    final cached = await _authDatasource.getCurrentUser();
    if (cached != null) {
      // refresh in background (don’t block UI)
      unawaited(_refreshCurrentUser());
      return Right(cached.toEntity());
    }

    // 2) if no cache, go network
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.whoAmI();
        await _authDatasource.saveUser(apiModel.toHiveModel()); // ✅ cache
        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch user',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return const Left(LocalDatabaseFailure(message: "No cached user"));
  }

  Future<void> _refreshCurrentUser() async {
    if (!await _networkInfo.isConnected) return;
    try {
      final apiModel = await _authRemoteDataSource.whoAmI();
      await _authDatasource.saveUser(apiModel.toHiveModel());
    } catch (_) {}
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
    if (await _networkInfo.isConnected) {
      try {
        if (image == null) {
          return const Left(ApiFailure(message: "Image path is required"));
        }

        final updatedModel = await _authRemoteDataSource.updateProfileImage(
          File(image),
        );

        // ✅ return ONLY image path
        final img = updatedModel.toEntity().image;
        if (img == null || img.isEmpty) {
          return const Left(
            ApiFailure(message: "No image returned from server"),
          );
        }

        return Right(img);
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

  @override
  Future<Either<Failure, bool>> deleteMe(String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _authRemoteDataSource.deleteMe(password);

        if (ok) {
          await _authDatasource.clearUser();
          await _tokenService.removeToken();
        }

        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Delete Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        LocalDatabaseFailure(message: "No internet connection"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestPasswordReset(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _authRemoteDataSource.requestPasswordReset(email);
        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Request failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        LocalDatabaseFailure(message: "No internet connection"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _authRemoteDataSource.resetPassword(
          email: email,
          code: code,
          newPassword: newPassword,
        );

        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Reset failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        LocalDatabaseFailure(message: "No internet connection"),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final updatedApi = await _authRemoteDataSource.updateUser(user);

        // cache/update locally
        final hive = updatedApi.toHiveModel();
        await _authDatasource.updateUser(hive);

        return Right(updatedApi.toEntity());
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
      try {
        final current = await _authDatasource.getCurrentUser();
        if (current == null || current.userId == null) {
          return const Left(LocalDatabaseFailure(message: "No logged in user"));
        }

        final updatedLocal = current.copyWith(
          username: user.username,
          email: user.email,
          phoneNumber: user.phoneNumber,
          location: user.location,
          gender: user.gender,
          dob: user.dob,
          image: user.image,
          role: user.role,
        );

        final saved = await _authDatasource.updateUser(updatedLocal);
        if (saved == null) {
          return const Left(LocalDatabaseFailure(message: "Update failed"));
        }

        return Right(saved.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> saveFcmToken(String token) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.saveFcmToken(token);
        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return const Left(LocalDatabaseFailure(message: "No internet"));
  }

  @override
  Future<Either<Failure, bool>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _authRemoteDataSource.verifyResetCode(
          email: email,
          code: code,
        );
        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Invalid code',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        LocalDatabaseFailure(message: "No internet connection"),
      );
    }
  }
}
