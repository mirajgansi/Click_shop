import 'dart:io';

import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:click_shop/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:click_shop/features/auth/data/models/auth_api_model.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockTokenService extends Mock implements TokenService {}

class FakeFile extends Fake implements File {}

void main() {
  late AuthRepository repository;
  late MockAuthLocalDataSource localDataSource;
  late MockAuthRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;
  late MockTokenService tokenService;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    localDataSource = MockAuthLocalDataSource();
    remoteDataSource = MockAuthRemoteDataSource();
    networkInfo = MockNetworkInfo();
    tokenService = MockTokenService();

    repository = AuthRepository(
      authDatasource: localDataSource,
      authRemoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
      tokenService: tokenService,
    );
  });

  const authEntity = AuthEntity(
    userId: 'u1',
    username: 'Miraj',
    email: 'miraj@test.com',
    password: 'password123',
  );

  final authHiveModel = AuthHiveModel(
    userId: 'u1',
    username: 'Miraj',
    email: 'miraj@test.com',
    password: 'password123',
  );

  final authApiModel = AuthApiModel(
    userId: 'u1',
    username: 'Miraj',
    email: 'miraj@test.com',
    password: 'password123',
  );

  DioException dioError({String message = 'failed', int statusCode = 400}) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: statusCode,
        data: {'message': message},
      ),
    );
  }

  group('getCurrentUser', () {
    test('returns failure when no cache and no internet', () async {
      when(
        () => localDataSource.getCurrentUser(),
      ).thenAnswer((_) async => null);
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getCurrentUser();

      expect(
        result,
        const Left(LocalDatabaseFailure(message: 'No cached user')),
      );
    });

    test('returns api failure when remote throws DioException', () async {
      when(
        () => localDataSource.getCurrentUser(),
      ).thenAnswer((_) async => null);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.whoAmI(),
      ).thenThrow(dioError(message: 'Failed to fetch user', statusCode: 401));

      final result = await repository.getCurrentUser();

      expect(
        result,
        const Left(
          ApiFailure(message: 'Failed to fetch user', statusCode: 401),
        ),
      );
    });
  });

  group('login', () {
    test('returns remote login user when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.login('miraj@test.com', 'password123'),
      ).thenAnswer((_) async => authApiModel);

      final result = await repository.login('miraj@test.com', 'password123');

      expect(result, Right(authApiModel.toEntity()));
    });

    test(
      'returns invalid credentials when remote login returns null',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remoteDataSource.login('miraj@test.com', 'password123'),
        ).thenAnswer((_) async => null);

        final result = await repository.login('miraj@test.com', 'password123');

        expect(result, const Left(ApiFailure(message: 'Invalid credentials')));
      },
    );

    test('returns local login user when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.login('miraj@test.com', 'password123'),
      ).thenAnswer((_) async => authHiveModel);

      final result = await repository.login('miraj@test.com', 'password123');

      expect(result, Right(authHiveModel.toEntity()));
    });

    test(
      'returns local database failure when offline login returns null',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => localDataSource.login('miraj@test.com', 'password123'),
        ).thenAnswer((_) async => null);

        final result = await repository.login('miraj@test.com', 'password123');

        expect(result, Left(LocalDatabaseFailure(message: 'Login failed')));
      },
    );
  });

  group('logout', () {
    test('returns true when logout succeeds', () async {
      when(() => localDataSource.logout()).thenAnswer((_) async => true);

      final result = await repository.logout();

      expect(result, const Right(true));
    });

    test('returns failure when logout fails', () async {
      when(() => localDataSource.logout()).thenAnswer((_) async => false);

      final result = await repository.logout();

      expect(result, Left(LocalDatabaseFailure(message: 'Logout failed')));
    });
  });

  group('register', () {
    test(
      'returns duplicate email failure when offline user already exists',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => localDataSource.getUserbyEmail(authEntity.email),
        ).thenAnswer((_) async => authHiveModel);

        final result = await repository.register(authEntity);

        expect(
          result,
          const Left(LocalDatabaseFailure(message: 'Email already registered')),
        );
      },
    );
  });

  group('updateProfileImage', () {
    test('returns failure when image is null', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);

      final result = await repository.updateProfileImage(null);

      expect(result, const Left(ApiFailure(message: 'Image path is required')));
    });

    test('returns failure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateProfileImage('/tmp/test.png');

      expect(
        result,
        const Left(
          ApiFailure(message: 'No internet connection. Cannot update user.'),
        ),
      );
    });

    test('returns image path when remote update succeeds', () async {
      final updatedModel = AuthApiModel(
        userId: 'u1',
        username: 'Miraj',
        email: 'miraj@test.com',
        password: 'password123',
        image: 'uploads/profile.png',
      );

      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.updateProfileImage(any()),
      ).thenAnswer((_) async => updatedModel);

      final result = await repository.updateProfileImage('/tmp/test.png');

      expect(result, const Right('uploads/profile.png'));
    });
  });

  group('deleteMe', () {
    test('clears local data and token when delete succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.deleteMe('password123'),
      ).thenAnswer((_) async => true);
      when(() => localDataSource.clearUser()).thenAnswer((_) async {});
      when(() => tokenService.removeToken()).thenAnswer((_) async {});

      final result = await repository.deleteMe('password123');

      expect(result, const Right(true));
      verify(() => localDataSource.clearUser()).called(1);
      verify(() => tokenService.removeToken()).called(1);
    });

    test('returns no internet failure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.deleteMe('password123');

      expect(
        result,
        const Left(LocalDatabaseFailure(message: 'No internet connection')),
      );
    });
  });

  group('requestPasswordReset', () {
    test('returns true when request succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.requestPasswordReset('miraj@test.com'),
      ).thenAnswer((_) async => true);

      final result = await repository.requestPasswordReset('miraj@test.com');

      expect(result, const Right(true));
    });

    test('returns offline failure when no internet', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.requestPasswordReset('miraj@test.com');

      expect(
        result,
        const Left(LocalDatabaseFailure(message: 'No internet connection')),
      );
    });
  });

  group('resetPassword', () {
    test('returns true when reset succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.resetPassword(
          email: 'miraj@test.com',
          code: '123456',
          newPassword: 'newpass123',
        ),
      ).thenAnswer((_) async => true);

      final result = await repository.resetPassword(
        email: 'miraj@test.com',
        code: '123456',
        newPassword: 'newpass123',
      );

      expect(result, const Right(true));
    });

    test(
      'returns offline failure when reset is called without internet',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.resetPassword(
          email: 'miraj@test.com',
          code: '123456',
          newPassword: 'newpass123',
        );

        expect(
          result,
          const Left(LocalDatabaseFailure(message: 'No internet connection')),
        );
      },
    );
  });

  group('updateUser', () {
    test('returns failure when offline and no logged in user exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.getCurrentUser(),
      ).thenAnswer((_) async => null);

      final result = await repository.updateUser(authEntity);

      expect(
        result,
        const Left(LocalDatabaseFailure(message: 'No logged in user')),
      );
    });
  });

  group('saveFcmToken', () {
    test('returns true when online save succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.saveFcmToken('token123'),
      ).thenAnswer((_) async => true);

      final result = await repository.saveFcmToken('token123');

      expect(result, const Right(true));
    });

    test('returns failure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.saveFcmToken('token123');

      expect(result, const Left(LocalDatabaseFailure(message: 'No internet')));
    });
  });

  group('verifyResetCode', () {
    test('returns true when code verification succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.verifyResetCode(
          email: 'miraj@test.com',
          code: '123456',
        ),
      ).thenAnswer((_) async => true);

      final result = await repository.verifyResetCode(
        email: 'miraj@test.com',
        code: '123456',
      );

      expect(result, const Right(true));
    });

    test('returns offline failure when no internet', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.verifyResetCode(
        email: 'miraj@test.com',
        code: '123456',
      );

      expect(
        result,
        const Left(LocalDatabaseFailure(message: 'No internet connection')),
      );
    });
  });
}
