import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:click_shop/features/driver/presentation/widgets/stats_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';

class DriverDashboardPage extends ConsumerStatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  ConsumerState<DriverDashboardPage> createState() =>
      _DriverDashboardPageState();
}

class _DriverDashboardPageState extends ConsumerState<DriverDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(driverViewModelProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(driverViewModelProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder(
              future: ref.read(getCurrentUserUsecaseProvider).call(),
              builder: (context, snapshot) {
                String name = "Driver";

                final data = snapshot.data;
                if (data != null) {
                  data.fold((_) {}, (user) {
                    // change fullName to whatever field your AuthEntity uses
                    name = (user.username?.isNotEmpty ?? false)
                        ? user.username!
                        : "Driver";
                  });
                }

                final now = DateTime.now();
                final greeting = now.hour < 12
                    ? "Good Morning"
                    : now.hour < 17
                    ? "Good Afternoon"
                    : "Good Evening";

                final formattedDate =
                    "${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}";

                final formattedTime =
                    "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "👋 $greeting, $name",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$formattedDate • $formattedTime",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  title: "Total Assigned",
                  value: state.stats.totalAssigned.toString(),
                  icon: Icons.local_shipping,
                  baseColor: Colors.amber,
                ),
                StatCard(
                  title: "Total Delivered",
                  value: state.stats.totalDelivered.toString(),
                  icon: Icons.check_circle,
                  baseColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              "Recent Activity",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Builder(
              builder: (_) {
                if (state.orders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        "No activity yet",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                // ✅ sort by latest activity (updatedAt > createdAt)
                final sorted = [...state.orders]
                  ..sort((a, b) {
                    final ad =
                        a.updatedAt ??
                        a.createdAt ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    final bd =
                        b.updatedAt ??
                        b.createdAt ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    return bd.compareTo(ad); // latest first
                  });

                final recent = sorted.take(5).toList();

                return Column(
                  children: recent.map((o) {
                    final shortId = o.id.length > 6
                        ? o.id.substring(0, 6)
                        : o.id;
                    final isDelivered = o.status.name == "delivered";
                    final date = o.updatedAt ?? o.createdAt;

                    final title = isDelivered
                        ? "Delivered Order #$shortId"
                        : "Assigned Order #$shortId";

                    final icon = isDelivered
                        ? Icons.check_circle
                        : Icons.local_shipping;
                    final iconColor = isDelivered ? Colors.green : Colors.amber;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(icon, color: iconColor),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "${_timeAgo(date)} • Total: Rs ${o.total}",
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return "Unknown";

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    final weeks = (diff.inDays / 7).floor();
    return "${weeks}w ago";
  }

  String _weekday(int day) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return days[day - 1];
  }

  String _month(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
