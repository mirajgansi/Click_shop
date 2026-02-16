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

    return Scaffold(
      appBar: AppBar(title: const Text("Driver Dashboard")),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(driverViewModelProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.status == DriverStatus.loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (state.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

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
                  icon: Icons.local_shipping_outlined,
                  baseColor: Colors.amber,
                ),
                StatCard(
                  title: "Total Delivered",
                  value: state.stats.totalDelivered.toString(),
                  icon: Icons.check_circle_outline,
                  baseColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              "Recent Assigned Orders",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            ...state.orders.take(5).map((o) {
              return Card(
                child: ListTile(
                  title: Text("Order #${o.id}"),
                  subtitle: Text("Status: ${o.status} • Total: ${o.total}"),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
