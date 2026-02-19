import 'package:click_shop/features/driver/presentation/widgets/status_pill_widget.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:flutter/material.dart';

class DriverOrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const DriverOrderCard({super.key, required this.order, this.onTap});
  String _shortId(String id, {int length = 5}) {
    if (id.length <= length) return id;
    return id.substring(0, length);
  }

  @override
  Widget build(BuildContext context) {
    final lastUpdated = order.updatedAt ?? order.createdAt;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Order #${_shortId(order.id)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusPill(
                        type: PillType.order,
                        value: order.status.name,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _buildAddress(order),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Phone number
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // LEFT: phone
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        order.shippingAddress?.phone ?? "N/A",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  // PUSH RIGHT
                  const Spacer(),

                  // RIGHT: time
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(lastUpdated),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildAddress(OrderEntity order) {
    final a = order.shippingAddress;
    if (a == null) return "No address";

    return [
      a.address1,
      a.address2,
      a.city,
    ].where((e) => e != null && e.isNotEmpty).join(", ");
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return "Unknown";

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}s ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else {
      final weeks = (diff.inDays / 7).floor();
      return "${weeks}w ago";
    }
  }
}
