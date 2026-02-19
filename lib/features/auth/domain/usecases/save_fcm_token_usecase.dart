import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaveFcmTokenParams extends Equatable {
  final String token;
  const SaveFcmTokenParams({required this.token});

  @override
  List<Object?> get props => [token];
}

final saveFcmTokenUsecaseProvider = Provider<SaveFcmTokenUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SaveFcmTokenUsecase(authRepository: repo);
});

class SaveFcmTokenUsecase
    implements UsecaseWithParams<bool, SaveFcmTokenParams> {
  final IAuthRepository _authRepository;

  SaveFcmTokenUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(SaveFcmTokenParams params) {
    return _authRepository.saveFcmToken(params.token);
  }
}
