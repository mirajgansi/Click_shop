import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/dashboard/data/repositories/notificatoin_repository.dart';
import 'package:click_shop/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final markAllNotificationsReadUsecaseProvider =
    Provider<MarkAllNotificationsReadUsecase>((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return MarkAllNotificationsReadUsecase(notificationRepository: repo);
    });

class MarkAllNotificationsReadUsecase implements UsecaseWithoutParams<bool> {
  final INotificationRepository _notificationRepository;

  MarkAllNotificationsReadUsecase({
    required INotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _notificationRepository.markAllNotificationsRead();
  }
}
