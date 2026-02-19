import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? error;

  const NotificationState({
    required this.isLoading,
    required this.notifications,
    required this.unreadCount,
    this.error,
  });

  /// Initial state
  factory NotificationState.initial() {
    return const NotificationState(
      isLoading: false,
      notifications: [],
      unreadCount: 0,
      error: null,
    );
  }

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, notifications, unreadCount, error];
}
