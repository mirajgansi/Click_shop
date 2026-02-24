import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:click_shop/features/dashboard/domain/usecases/get_my_notification_usecase.dart';
import 'package:click_shop/features/dashboard/domain/usecases/get_unread_count_usecase.dart';
import 'package:click_shop/features/dashboard/domain/usecases/mark_all_notification_usecase.dart';
import 'package:click_shop/features/dashboard/domain/usecases/mark_notification_read_usecase.dart';
import 'package:click_shop/features/dashboard/presentation/providers/notification_settings_provider.dart';
import 'package:click_shop/features/dashboard/presentation/state/notification_state.dart';
import 'package:click_shop/features/dashboard/presentation/view_model/notification_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMyNotificationsUsecase extends Mock
    implements GetMyNotificationsUsecase {}

class MockGetUnreadCountUsecase extends Mock implements GetUnreadCountUsecase {}

class MockMarkNotificationReadUsecase extends Mock
    implements MarkNotificationReadUsecase {}

class MockMarkAllNotificationsReadUsecase extends Mock
    implements MarkAllNotificationsReadUsecase {}

class FakeGetMyParams extends Fake implements GetMyNotificationsParams {}

class FakeUnreadParams extends Fake implements GetUnreadCountParams {}

class FakeMarkReadParams extends Fake implements MarkNotificationReadParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetMyParams());
    registerFallbackValue(FakeUnreadParams());
    registerFallbackValue(FakeMarkReadParams());
  });

  ProviderContainer makeContainer({
    required MockGetMyNotificationsUsecase getMy,
    required MockGetUnreadCountUsecase unread,
    required MockMarkNotificationReadUsecase markRead,
    required MockMarkAllNotificationsReadUsecase markAll,
    bool notificationsEnabled =
        false, // keep false to avoid local notifications
  }) {
    return ProviderContainer(
      overrides: [
        getMyNotificationsUsecaseProvider.overrideWithValue(getMy),
        getUnreadCountUsecaseProvider.overrideWithValue(unread),
        markNotificationReadUsecaseProvider.overrideWithValue(markRead),
        markAllNotificationsReadUsecaseProvider.overrideWithValue(markAll),
      ],
    );
  }

  NotificationEntity n({required String id, bool isRead = false}) {
    // ✅ Adjust constructor if your NotificationEntity differs
    return NotificationEntity(
      id: id,
      title: 'T$id',
      message: 'M$id',
      isRead: isRead,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  group('NotificationViewModel', () {
    test('load success -> sets notifications + unreadCount', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      final list = [n(id: '1', isRead: false), n(id: '2', isRead: true)];

      when(() => mockGetMy(any())).thenAnswer((_) async => Right(list));

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      final vm = container.read(notificationViewModelProvider.notifier);
      await vm.load();

      final st = container.read(notificationViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.notifications.length, 2);
      expect(st.unreadCount, 1);
      expect(st.error, isNull);

      verify(() => mockGetMy(any())).called(1);
    });

    test('load failure -> sets error', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      when(() => mockGetMy(any())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'fail', statusCode: 500)),
      );

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      final vm = container.read(notificationViewModelProvider.notifier);
      await vm.load();

      final st = container.read(notificationViewModelProvider);
      expect(st.isLoading, isFalse);
      expect(st.error, 'fail');
      verify(() => mockGetMy(any())).called(1);
    });

    test('loadUnreadCount success -> updates unreadCount', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      when(() => mockUnread(any())).thenAnswer((_) async => const Right(7));

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      final vm = container.read(notificationViewModelProvider.notifier);
      await vm.loadUnreadCount();

      final st = container.read(notificationViewModelProvider);
      expect(st.unreadCount, 7);
      expect(st.error, isNull);
      verify(() => mockUnread(any())).called(1);
    });

    test('loadUnreadCount failure -> stores error (does not crash)', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      when(() => mockUnread(any())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'count fail', statusCode: 500)),
      );

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      final vm = container.read(notificationViewModelProvider.notifier);
      await vm.loadUnreadCount();

      final st = container.read(notificationViewModelProvider);
      expect(st.error, 'count fail');
      verify(() => mockUnread(any())).called(1);
    });

    test('markRead -> optimistic update + calls API', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      when(
        () => mockMarkRead(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      // seed state
      container
          .read(notificationViewModelProvider.notifier)
          .state = NotificationState.initial().copyWith(
        notifications: [
          n(id: '1', isRead: false),
          n(id: '2', isRead: false),
        ],
        unreadCount: 2,
      );

      final vm = container.read(notificationViewModelProvider.notifier);
      await vm.markRead('1');

      final st = container.read(notificationViewModelProvider);
      expect(st.notifications.firstWhere((x) => x.id == '1').isRead, isTrue);
      expect(st.unreadCount, 1);
      expect(st.error, isNull);

      verify(() => mockMarkRead(any())).called(1);
    });

    test(
      'markRead API failure -> keeps optimistic change but sets error',
      () async {
        final mockGetMy = MockGetMyNotificationsUsecase();
        final mockUnread = MockGetUnreadCountUsecase();
        final mockMarkRead = MockMarkNotificationReadUsecase();
        final mockMarkAll = MockMarkAllNotificationsReadUsecase();

        when(() => mockMarkRead(any())).thenAnswer(
          (_) async => Left(ApiFailure(message: 'api fail', statusCode: 500)),
        );

        final container = makeContainer(
          getMy: mockGetMy,
          unread: mockUnread,
          markRead: mockMarkRead,
          markAll: mockMarkAll,
        );
        addTearDown(container.dispose);

        container
            .read(notificationViewModelProvider.notifier)
            .state = NotificationState.initial().copyWith(
          notifications: [n(id: '1', isRead: false)],
          unreadCount: 1,
        );

        final vm = container.read(notificationViewModelProvider.notifier);
        await vm.markRead('1');

        final st = container.read(notificationViewModelProvider);
        expect(st.notifications.first.isRead, isTrue);
        expect(st.unreadCount, 0);
        expect(st.error, 'api fail');

        verify(() => mockMarkRead(any())).called(1);
      },
    );

    test(
      'markAllRead -> optimistic sets all read + unreadCount 0 + calls API',
      () async {
        final mockGetMy = MockGetMyNotificationsUsecase();
        final mockUnread = MockGetUnreadCountUsecase();
        final mockMarkRead = MockMarkNotificationReadUsecase();
        final mockMarkAll = MockMarkAllNotificationsReadUsecase();

        when(() => mockMarkAll()).thenAnswer((_) async => const Right(true));

        final container = makeContainer(
          getMy: mockGetMy,
          unread: mockUnread,
          markRead: mockMarkRead,
          markAll: mockMarkAll,
        );
        addTearDown(container.dispose);

        container
            .read(notificationViewModelProvider.notifier)
            .state = NotificationState.initial().copyWith(
          notifications: [
            n(id: '1', isRead: false),
            n(id: '2', isRead: true),
          ],
          unreadCount: 1,
        );

        final vm = container.read(notificationViewModelProvider.notifier);
        await vm.markAllRead();

        final st = container.read(notificationViewModelProvider);
        expect(st.unreadCount, 0);
        expect(st.notifications.every((x) => x.isRead), isTrue);
        expect(st.error, isNull);

        verify(() => mockMarkAll()).called(1);
      },
    );

    test(
      'refresh -> calls load and loadUnreadCount with forceRefresh true',
      () async {
        final mockGetMy = MockGetMyNotificationsUsecase();
        final mockUnread = MockGetUnreadCountUsecase();
        final mockMarkRead = MockMarkNotificationReadUsecase();
        final mockMarkAll = MockMarkAllNotificationsReadUsecase();

        when(
          () => mockGetMy(any()),
        ).thenAnswer((_) async => const Right(<NotificationEntity>[]));
        when(() => mockUnread(any())).thenAnswer((_) async => const Right(0));

        final container = makeContainer(
          getMy: mockGetMy,
          unread: mockUnread,
          markRead: mockMarkRead,
          markAll: mockMarkAll,
        );
        addTearDown(container.dispose);

        final vm = container.read(notificationViewModelProvider.notifier);
        await vm.refresh();

        verify(() => mockGetMy(any())).called(1);
        verify(() => mockUnread(any())).called(1);
      },
    );

    test('onSocketNotification duplicate -> ignores', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      container
          .read(notificationViewModelProvider.notifier)
          .state = NotificationState.initial().copyWith(
        notifications: [n(id: 'dup', isRead: false)],
        unreadCount: 1,
      );

      final vm = container.read(notificationViewModelProvider.notifier);

      final payload = <String, dynamic>{
        '_id': 'dup',
        'title': 'Hi',
        'message': 'Again',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      vm.onSocketNotification(payload);

      final st = container.read(notificationViewModelProvider);
      expect(st.notifications.length, 1); // unchanged
      expect(st.unreadCount, 1);
    });

    test('onSocketNotification invalid payload -> sets error', () async {
      final mockGetMy = MockGetMyNotificationsUsecase();
      final mockUnread = MockGetUnreadCountUsecase();
      final mockMarkRead = MockMarkNotificationReadUsecase();
      final mockMarkAll = MockMarkAllNotificationsReadUsecase();

      final container = makeContainer(
        getMy: mockGetMy,
        unread: mockUnread,
        markRead: mockMarkRead,
        markAll: mockMarkAll,
      );
      addTearDown(container.dispose);

      final vm = container.read(notificationViewModelProvider.notifier);

      vm.onSocketNotification('bad payload'); // not a map

      final st = container.read(notificationViewModelProvider);
      expect(st.error, 'Invalid socket notification payload');
    });
  });
}
