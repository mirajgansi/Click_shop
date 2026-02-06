import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateProfileUsecaseParams extends Equatable {
  String? image;
  UpdateProfileUsecaseParams({this.image});

  @override
  List<Object?> get props => [image];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateProfileUsecase(repository: authRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<String, UpdateProfileUsecaseParams> {
  final IAuthRepository _repository;

  UpdateProfileUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, String>> call(UpdateProfileUsecaseParams params) {
    return _repository.updateProfileImage(params.image);
  }
}
