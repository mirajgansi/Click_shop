import 'package:click_shop/features/order/presentation/pages/prder_detail_page.dart';
import 'package:click_shop/features/order/presentation/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';

class MyOrdersPage extends ConsumerStatefulWidget {
  const MyOrdersPage({super.key});

  @override
  ConsumerState<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends ConsumerState<MyOrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(orderViewModelProvider.notifier).loadMyOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(orderViewModelProvider.notifier).loadMyOrders(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
            ? ListView(
                children: [
                  const SizedBox(height: 140),
                  Center(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            : state.orders.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 140),
                  Center(child: Text("No orders yet")),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailPage(orderId: order.id),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
