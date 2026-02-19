import 'package:click_shop/features/driver/presentation/pages/order_detail_page.dart';
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/widgets/assigned_page_sekeleton.dart';
import 'package:click_shop/features/driver/presentation/widgets/driver_card_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveredPage extends ConsumerStatefulWidget {
  const DeliveredPage({super.key});

  @override
  ConsumerState<DeliveredPage> createState() => _DeliveredPageState();
}

class _DeliveredPageState extends ConsumerState<DeliveredPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(driverViewModelProvider.notifier).loadMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    final deliveredOrders = state.orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(driverViewModelProvider.notifier).loadMyOrders(),
        child: Builder(
          builder: (_) {
            if (state.status == DriverStatus.loading) {
              return const AssignedPageSkeleton();
            }

            if (state.status == DriverStatus.error) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 150),
                  Center(
                    child: Text(
                      state.errorMessage ?? "Something went wrong",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () => ref
                          .read(driverViewModelProvider.notifier)
                          .loadMyOrders(),
                      child: const Text("Try again"),
                    ),
                  ),
                ],
              );
            }

            if (deliveredOrders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Image.asset(
                      "assets/images/no_orders.jpg",
                      width: MediaQuery.of(context).size.width * 0.65,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "No delivered orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: deliveredOrders.length,
              itemBuilder: (context, index) {
                final order = deliveredOrders[index];

                return DriverOrderCard(
                  order: order,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DriverOrderDetailPage(order: order),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
