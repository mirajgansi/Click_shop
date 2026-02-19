import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/dashboard/data/repositories/notificatoin_repository.dart';
import 'package:click_shop/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUnreadCountParams extends Equatable {
  final bool forceRefresh;

  const GetUnreadCountParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

final getUnreadCountUsecaseProvider = Provider<GetUnreadCountUsecase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetUnreadCountUsecase(notificationRepository: repo);
});

class GetUnreadCountUsecase
    implements UsecaseWithParams<int, GetUnreadCountParams> {
  final INotificationRepository _notificationRepository;

  GetUnreadCountUsecase({
    required INotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, int>> call(GetUnreadCountParams params) {
    return _notificationRepository.getUnreadCount(
      forceRefresh: params.forceRefresh,
    );
  }
}
