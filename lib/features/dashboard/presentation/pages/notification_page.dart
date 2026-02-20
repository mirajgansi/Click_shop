import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/dashboard/presentation/view_model/notification_view_model.dart';
import 'package:click_shop/features/dashboard/presentation/state/notification_state.dart';
import 'package:click_shop/features/order/presentation/pages/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({
    super.key,
    this.title = "Notifications",
    this.showAppBar = true,
  });

  final String title;
  final bool showAppBar;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationViewModelProvider.notifier).load();
      ref.read(notificationViewModelProvider.notifier).loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);

    ref.listen<NotificationState>(notificationViewModelProvider, (prev, next) {
      final err = next.error;
      if (err != null && err.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
        ref.read(notificationViewModelProvider.notifier).clearError();
      }
    });

    final body = RefreshIndicator(
      onRefresh: () =>
          ref.read(notificationViewModelProvider.notifier).refresh(),
      child: state.isLoading && state.notifications.isEmpty
          ? const _NotificationSkeleton()
          : state.notifications.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text("No notifications")),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = state.notifications[index];

                return _NotificationTile(
                  title: n.title,
                  message: n.message,
                  createdAt: n.createdAt,
                  isRead: n.isRead,
                  onTap: () async {
                    // 1) Debug: confirm tap is firing
                    debugPrint("Notification tapped: id=${n.id}");

                    // 2) Get orderId (must exist in your notification model)
                    final orderId =
                        n.orderId; // <-- make sure this field exists

                    debugPrint("orderId from notification = $orderId");

                    // 3) Navigate if orderId exists
                    if (orderId != null && orderId.trim().isNotEmpty) {
                      // Use rootNavigator in case you're inside tabs/bottom nav
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(orderId: orderId),
                        ),
                      );
                    } else {
                      SnackbarUtils.showError(
                        context,
                        "No orderId in this notification",
                      );
                    }

                    // 4) Mark read (after navigation is fine)
                    ref
                        .read(notificationViewModelProvider.notifier)
                        .markRead(n.id);
                  },
                );
              },
            ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            const SizedBox(width: 10),
            if (state.unreadCount > 0) _UnreadBadge(count: state.unreadCount),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Mark all read",
            onPressed: state.notifications.isEmpty
                ? null
                : () => ref
                      .read(notificationViewModelProvider.notifier)
                      .markAllRead(),
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.onTap,
  });

  final String title;
  final String message;
  final String createdAt;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isRead
          ? theme.cardColor
          : theme.colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Dot(isRead: isRead),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                size: 20,
                color: isRead
                    ? theme.textTheme.bodySmall?.color?.withOpacity(0.6)
                    : theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : cs.primary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isRead ? cs.outline.withOpacity(0.5) : cs.primary,
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          height: 84,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
        );
      },
    );
  }
}
