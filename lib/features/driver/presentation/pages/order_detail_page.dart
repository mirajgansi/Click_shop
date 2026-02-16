import 'package:click_shop/features/driver/presentation/view_model/driver_view_model.dart';
import 'package:click_shop/features/driver/presentation/widgets/driver_order_dailog.dart';
import 'package:click_shop/features/driver/presentation/widgets/item_tile_widget.dart';
import 'package:click_shop/features/driver/presentation/widgets/row_text_widget.dart';
import 'package:click_shop/features/driver/presentation/widgets/section_car_widget.dart';
import 'package:click_shop/features/driver/presentation/widgets/status_pill_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriverOrderDetailPage extends ConsumerWidget {
  final OrderEntity order;

  const DriverOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final a = order.shippingAddress;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        title: Text(
          "Order Details",
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SectionCarWidget(
            title: "Delivery",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowText(label: "Name", value: a?.userName ?? "N/A"),
                RowText(label: "Phone", value: a?.phone ?? "N/A"),
                RowText(label: "Address", value: _addressText()),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SectionCarWidget(
            title: "Items (${order.items.length})",
            child: Column(
              children: [
                for (final item in order.items) ...[
                  ItemTile(
                    name: item.name,
                    qty: item.quantity,
                    price: item.price,
                    total: item.lineTotal,
                    imagePath: item.image,
                  ),
                  Divider(
                    height: 16,
                    color: cs.outlineVariant.withOpacity(0.6),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),
          SectionCarWidget(
            title: "Totals",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowText(
                  label: "Subtotal",
                  value: "Rs ${order.subtotal.toStringAsFixed(0)}",
                ),
                RowText(
                  label: "Shipping",
                  value: "Rs ${order.shippingFee.toStringAsFixed(0)}",
                ),
                const SizedBox(height: 10),

                RowText(
                  label: "Total",
                  value: "Rs ${order.total.toStringAsFixed(0)}",
                  valueStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(type: PillType.order, value: order.status.name),
                    StatusPill(
                      type: PillType.payment,
                      value: order.paymentStatus.name,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SectionCarWidget(
            title: "Notes & Time",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowText(
                  label: "Notes",
                  value: order.notes?.trim().isNotEmpty == true
                      ? order.notes!
                      : "N/A",
                ),
                const SizedBox(height: 8),
                RowText(label: "Created", value: _dt(order.createdAt)),
                RowText(label: "Updated", value: _dt(order.updatedAt)),
              ],
            ),
          ),
          if (order.status == OrderStatus.shipped) ...[
            const SizedBox(height: 12),

            Card(
              color: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Actions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text("Mark as Delivered"),
                        onPressed: () async {
                          final ok = await DriverOrderDialogs.confirmDelivered(
                            context,
                          );
                          if (!ok) return;

                          final vm = ref.read(driverViewModelProvider.notifier);

                          await vm.updateOrderStatus(
                            orderId: order.id,
                            status: "delivered",
                            refreshAfter: true,
                          );

                          await DriverOrderDialogs.showDeliverySuccess(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _addressText() {
    final a = order.shippingAddress;
    if (a == null) return "No address";

    final parts = [a.address1, a.address2, a.city, a.zip]
        .where((e) => e != null && e!.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();

    return parts.isEmpty ? "No address" : parts.join(", ");
  }

  String _dt(DateTime? d) {
    if (d == null) return "N/A";
    // simple readable format
    final local = d.toLocal();
    return "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} "
        "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}
