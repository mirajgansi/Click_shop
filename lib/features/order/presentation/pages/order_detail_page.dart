import 'package:click_shop/core/utils/snackbar_utils.dart';
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
    final cs = Theme.of(context).colorScheme;

    final order = state.selectedOrder;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          "Order Details",
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
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

        ...order.items.map((item) => _ItemTile(item: item)),

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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Order #${order.id}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            ),
            child: Text(
              order.paymentStatus.name.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: cs.onSurface,
              ),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 18,
            color: cs.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Status: ${status.toUpperCase()}",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            canCancel ? "Cancelable" : "Locked",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: canCancel ? cs.primary : cs.error,
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
    final cs = Theme.of(context).colorScheme;

    final s = order.shippingAddress!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shipping Address",
            style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
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
            style: TextStyle(color: cs.onSurface),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
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
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
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
    final cs = Theme.of(context).colorScheme;

    Widget row(String left, num right, {bool bold = false}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          Text(
            "Rs.$right",
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          row("Subtotal", order.subtotal),
          const SizedBox(height: 6),
          row("Shipping", order.shippingFee),
          Divider(height: 18, color: cs.outlineVariant.withOpacity(0.6)),
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
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(orderViewModelProvider);

    final currentOrder = state.selectedOrder ?? order;
    final canCancel = currentOrder.status.name.toLowerCase() == "pending";

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canCancel ? cs.error : cs.surfaceContainerHighest,
          foregroundColor: canCancel ? cs.onError : cs.onSurfaceVariant,
          disabledBackgroundColor: cs.onSurfaceVariant,
          disabledForegroundColor: cs.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: state.isLoading
            ? null
            : () async {
                if (!canCancel) {
                  SnackbarUtils.showError(
                    context,
                    "Orders can’t be cancelled after shipping.",
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

                try {
                  await ref
                      .read(orderViewModelProvider.notifier)
                      .cancelMyOrder(currentOrder.id);
                } finally {
                  await ref
                      .read(orderViewModelProvider.notifier)
                      .getOrderById(currentOrder.id);
                }

                if (!context.mounted) return;

                final st = ref.read(orderViewModelProvider);
                if (st.errorMessage != null) {
                  SnackbarUtils.showError(context, st.errorMessage!);
                } else {
                  SnackbarUtils.showSuccess(context, "Order Cancelled");
                }
              },
        child: state.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: canCancel ? cs.onError : cs.onSurface,
                ),
              )
            : Text(
                canCancel ? "Cancel Order" : "Locked",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
      ),
    );
  }
}
