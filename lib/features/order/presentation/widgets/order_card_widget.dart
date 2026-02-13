import 'package:click_shop/features/driver/presentation/widgets/status_pill_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final orderId = (order.id.isNotEmpty) ? order.id : "N/A";
    final shortId = orderId.length > 8
        ? orderId.substring(orderId.length - 8)
        : orderId;

    final total = order.total;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface, // ✅ was white
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.4), // ✅ was grey
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Order #$shortId",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: cs.onSurface, // ✅
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusPill(type: PillType.order, value: order.status.name),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: Rs.${total.toString()}",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "${order.items.length} item(s)",
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.6), // ✅ was black54
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.year}-${dt.month.toString().padLeft(2, "0")}-${dt.day.toString().padLeft(2, "0")}";
  }
}
