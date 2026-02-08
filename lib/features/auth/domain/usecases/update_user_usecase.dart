import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateUserParams extends Equatable {
  final AuthEntity user;
  const UpdateUserParams({required this.user});

  @override
  List<Object?> get props => [user];
}

// provider
final updateUserUsecaseProvider = Provider<UpdateUserUsecase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return UpdateUserUsecase(authRepository: repo);
});

class UpdateUserUsecase
    implements UsecaseWithParams<AuthEntity, UpdateUserParams> {
  final IAuthRepository _authRepository;

  UpdateUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateUserParams params) {
    return _authRepository.updateUser(params.user);
  }
}
