import 'package:click_shop/features/driver/presentation/state/driver_state.dart';
import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/widgets/driver_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriverPage extends ConsumerStatefulWidget {
  const DriverPage({super.key});

  @override
  ConsumerState<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends ConsumerState<DriverPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(driverViewModelProvider.notifier).loadMyOrders(),
          ),
        ],
      ),
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
                  const SizedBox(height: 150),
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

            if (state.orders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(child: Text("No assigned orders yet")),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];

                return DriverOrderCard(
                  order: order,
                  onTap: () {
                    // optional: open details page
                    // Navigator.pushNamed(context, "/driver/order", arguments: order);
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
