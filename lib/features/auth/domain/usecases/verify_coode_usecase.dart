import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final verifyResetCodeUsecaseProvider = Provider<VerifyResetCodeUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return VerifyResetCodeUsecase(repo);
});

class VerifyResetCodeParams {
  final String email;
  final String code;

  VerifyResetCodeParams({required this.email, required this.code});
}

class VerifyResetCodeUsecase
    implements UsecaseWithParams<bool, VerifyResetCodeParams> {
  final IAuthRepository _repo;

  VerifyResetCodeUsecase(this._repo);

  @override
  Future<Either<Failure, bool>> call(VerifyResetCodeParams params) {
    return _repo.verifyResetCode(email: params.email, code: params.code);
  }
}
