import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteMeParams extends Equatable {
  final String password;
  const DeleteMeParams({required this.password});

  @override
  List<Object?> get props => [password];
}

// provider
final deleteMeUsecaseProvider = Provider<DeleteMeUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return DeleteMeUsecase(authRepository: repo);
});

class DeleteMeUsecase implements UsecaseWithParams<bool, DeleteMeParams> {
  final IAuthRepository _authRepository;

  DeleteMeUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteMeParams params) {
    return _authRepository.deleteMe(params.password);
  }
}
