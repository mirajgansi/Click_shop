import 'package:click_shop/features/driver/presentation/pages/order_detail_page.dart';
import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/widgets/driver_card_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignedPage extends ConsumerStatefulWidget {
  const AssignedPage({super.key});

  @override
  ConsumerState<AssignedPage> createState() => _AssignedPageState();
}

class _AssignedPageState extends ConsumerState<AssignedPage> {
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

    final assignedOrders = state.orders
        .where((o) => o.status == OrderStatus.shipped)
        .toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(driverViewModelProvider.notifier).loadMyOrders(),
        child: Builder(
          builder: (_) {
            if (state.status == DriverStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DriverStatus.error) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      state.errorMessage ?? "Something went wrong",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(driverViewModelProvider.notifier)
                          .loadMyOrders(),
                      child: const Text("Try again"),
                    ),
                  ),
                ],
              );
            }

            if (assignedOrders.isEmpty) {
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
                  const Center(
                    child: Text(
                      "No assigned orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: assignedOrders.length,
              itemBuilder: (context, index) {
                final order = assignedOrders[index];

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
