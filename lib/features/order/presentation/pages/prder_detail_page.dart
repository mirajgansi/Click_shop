import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderViewModelProvider.notifier).getOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);

    final order = state.selectedOrder;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : order == null
          ? const Center(child: Text("Order not found"))
          : _Body(order: order),
      bottomNavigationBar: order == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _CancelButton(order: order),
              ),
            ),
    );
  }
}

class _Body extends StatelessWidget {
  final OrderEntity order;

  const _Body({required this.order});

  @override
  Widget build(BuildContext context) {
    final canCancel = order.status.name == "pending";

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        _HeaderCard(order: order),
        const SizedBox(height: 12),

        _StatusCard(status: order.status.name, canCancel: canCancel),
        const SizedBox(height: 12),

        if (order.shippingAddress != null) ...[
          _ShippingCard(order: order),
          const SizedBox(height: 12),
        ],

        const Text(
          "Items",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),

        ...order.items.map((item) => _ItemTile(item: item)).toList(),

        const SizedBox(height: 14),
        _TotalsCard(order: order),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final OrderEntity order;

  const _HeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Order #${order.id}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              order.paymentStatus.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final bool canCancel;

  const _StatusCard({required this.status, required this.canCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 18,
            color: Colors.black54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Status: ${status.toUpperCase()}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            canCancel ? "Cancelable" : "Locked",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: canCancel ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingCard extends StatelessWidget {
  final OrderEntity order;

  const _ShippingCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final s = order.shippingAddress!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shipping Address",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "${s.userName ?? ""} • ${s.phone ?? ""}",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            [s.address1, s.address2, s.city, s.zip]
                .where((e) => (e ?? "").trim().isNotEmpty)
                .map((e) => e!)
                .join(", "),
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final OrderItemEntity item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.lineTotal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity}  •  Rs.${item.price}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Rs.$lineTotal",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final OrderEntity order;

  const _TotalsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    Widget row(String left, num right, {bool bold = false}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            "Rs.$right",
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          row("Subtotal", order.subtotal),
          const SizedBox(height: 6),
          row("Shipping", order.shippingFee),
          const Divider(height: 18),
          row("Total", order.total, bold: true),
        ],
      ),
    );
  }
}

class _CancelButton extends ConsumerWidget {
  final OrderEntity order;

  const _CancelButton({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderViewModelProvider);
    final canCancel = order.status.name == "pending";

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canCancel ? Colors.redAccent : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: state.isLoading
            ? null
            : () async {
                if (!canCancel) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "You can only cancel when the order is pending.",
                      ),
                    ),
                  );
                  return;
                }

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Cancel Order?"),
                    content: const Text(
                      "Are you sure you want to cancel this order?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Yes, cancel"),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                await ref
                    .read(orderViewModelProvider.notifier)
                    .cancelMyOrder(order.id);

                final st = ref.read(orderViewModelProvider);

                if (st.errorMessage != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(st.errorMessage!)));
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Order cancelled ✅")),
                );

                await ref
                    .read(orderViewModelProvider.notifier)
                    .getOrderById(order.id);
              },
        child: state.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                canCancel ? "Cancel Order" : "Cannot Cancel",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
      ),
    );
  }
}
