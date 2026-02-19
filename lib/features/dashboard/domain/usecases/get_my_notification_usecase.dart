import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/dashboard/data/repositories/notificatoin_repository.dart';
import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:click_shop/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetMyNotificationsParams extends Equatable {
  final bool forceRefresh;

  const GetMyNotificationsParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

final getMyNotificationsUsecaseProvider = Provider<GetMyNotificationsUsecase>((
  ref,
) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetMyNotificationsUsecase(notificationRepository: repo);
});

class GetMyNotificationsUsecase
    implements
        UsecaseWithParams<List<NotificationEntity>, GetMyNotificationsParams> {
  final INotificationRepository _notificationRepository;

  GetMyNotificationsUsecase({
    required INotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetMyNotificationsParams params,
  ) {
    return _notificationRepository.getMyNotifications(
      forceRefresh: params.forceRefresh,
    );
  }
}
