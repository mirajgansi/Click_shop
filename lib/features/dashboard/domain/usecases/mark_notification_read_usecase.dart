import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/dashboard/data/repositories/notificatoin_repository.dart';
import 'package:click_shop/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkNotificationReadParams extends Equatable {
  final String id;

  const MarkNotificationReadParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final markNotificationReadUsecaseProvider =
    Provider<MarkNotificationReadUsecase>((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return MarkNotificationReadUsecase(notificationRepository: repo);
    });

class MarkNotificationReadUsecase
    implements UsecaseWithParams<bool, MarkNotificationReadParams> {
  final INotificationRepository _notificationRepository;

  MarkNotificationReadUsecase({
    required INotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, bool>> call(MarkNotificationReadParams params) {
    return _notificationRepository.markNotificationRead(params.id);
  }
}
