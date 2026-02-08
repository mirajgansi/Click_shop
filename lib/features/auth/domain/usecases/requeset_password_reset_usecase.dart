import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestPasswordResetParams extends Equatable {
  final String email;
  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return RequestPasswordResetUsecase(authRepository: repo);
    });

class RequestPasswordResetUsecase
    implements UsecaseWithParams<bool, RequestPasswordResetParams> {
  final IAuthRepository _authRepository;

  RequestPasswordResetUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RequestPasswordResetParams params) {
    return _authRepository.requestPasswordReset(params.email);
  }
}
