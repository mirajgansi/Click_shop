import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity authEntity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, String>> updateProfileImage(String? image);
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity authEntity);

  Future<Either<Failure, bool>> deleteMe(String password);

  Future<Either<Failure, bool>> requestPasswordReset(String email);
  Future<Either<Failure, bool>> saveFcmToken(String token);

  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String code, // keep as String (to preserve leading zeros)
    required String newPassword,
  });
  Future<Either<Failure, bool>> verifyResetCode({
    required String email,
    required String code,
  });
}
