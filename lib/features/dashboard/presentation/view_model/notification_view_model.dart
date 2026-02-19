import 'package:click_shop/features/dashboard/domain/usecases/get_my_notification_usecase.dart';
import 'package:click_shop/features/dashboard/domain/usecases/get_unread_count_usecase.dart';
import 'package:click_shop/features/dashboard/domain/usecases/mark_all_notification_usecase.dart';
import 'package:click_shop/features/dashboard/domain/usecases/mark_notification_read_usecase.dart';
import 'package:click_shop/features/dashboard/presentation/state/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      () => NotificationViewModel(),
    );

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetMyNotificationsUsecase _getMyNotificationsUsecase;
  late final GetUnreadCountUsecase _getUnreadCountUsecase;
  late final MarkNotificationReadUsecase _markNotificationReadUsecase;
  late final MarkAllNotificationsReadUsecase _markAllNotificationsReadUsecase;

  @override
  NotificationState build() {
    _getMyNotificationsUsecase = ref.read(getMyNotificationsUsecaseProvider);
    _getUnreadCountUsecase = ref.read(getUnreadCountUsecaseProvider);
    _markNotificationReadUsecase = ref.read(
      markNotificationReadUsecaseProvider,
    );
    _markAllNotificationsReadUsecase = ref.read(
      markAllNotificationsReadUsecaseProvider,
    );

    return NotificationState.initial();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> load({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getMyNotificationsUsecase(
      GetMyNotificationsParams(forceRefresh: forceRefresh),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (notifications) {
        final unread = notifications.where((n) => !n.isRead).length;
        state = state.copyWith(
          isLoading: false,
          notifications: notifications,
          unreadCount: unread,
          error: null,
        );
      },
    );
  }

  Future<void> loadUnreadCount({bool forceRefresh = false}) async {
    final result = await _getUnreadCountUsecase(
      GetUnreadCountParams(forceRefresh: forceRefresh),
    );

    result.fold(
      (failure) {
        // don’t break UI, just store error
        state = state.copyWith(error: failure.message);
      },
      (count) {
        state = state.copyWith(unreadCount: count, error: null);
      },
    );
  }

  Future<void> markRead(String id) async {
    if (id.isEmpty) return;

    // optimistic UI update
    final updatedList = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: updatedList.where((n) => !n.isRead).length,
      error: null,
    );

    final result = await _markNotificationReadUsecase(
      MarkNotificationReadParams(id: id),
    );

    result.fold((failure) {
      // if API fails you can either revert or just show error
      state = state.copyWith(error: failure.message);
    }, (_) {});
  }

  Future<void> markAllRead() async {
    // optimistic UI update
    final updatedList = state.notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();

    state = state.copyWith(
      notifications: updatedList,
      unreadCount: 0,
      error: null,
    );

    final result = await _markAllNotificationsReadUsecase();

    result.fold((failure) {
      state = state.copyWith(error: failure.message);
    }, (_) {});
  }

  Future<void> refresh() async {
    await load(forceRefresh: true);
    await loadUnreadCount(forceRefresh: true);
  }
}
