import 'package:flutter/material.dart';

enum PillType { order, payment }

// Optional: if you already have enums in your domain, you can pass String instead.
// This widget supports both by taking `value` as String.
class StatusPill extends StatelessWidget {
  final PillType type;
  final String value; // "shipped" | "delivered" | "paid" | etc.
  final bool showDot;
  final bool showIcon;

  const StatusPill({
    super.key,
    required this.type,
    required this.value,
    this.showDot = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final ui = _resolve(type, value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ui.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ui.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(ui.icon, size: 16, color: ui.text),
            const SizedBox(width: 6),
          ],
          Text(
            ui.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ui.text,
            ),
          ),
        ],
      ),
    );
  }

  _PillUi _resolve(PillType type, String valueRaw) {
    final value = valueRaw.toLowerCase();

    if (type == PillType.payment) {
      if (value == "paid") {
        return _PillUi(
          label: "Success",
          icon: Icons.credit_card,
          bg: const Color(0xFFE8F5E9),
          text: const Color(0xFF2E7D32),
          border: const Color(0xFFC8E6C9),
          dot: const Color(0xFF4CAF50),
        );
      }
      return _PillUi(
        label: "Unpaid",
        icon: Icons.schedule,
        bg: const Color(0xFFFFF8E1),
        text: const Color(0xFF8D6E00),
        border: const Color(0xFFFFECB3),
        dot: const Color(0xFFFFC107),
      );
    }

    // Order statuses
    switch (value) {
      case "pending":
        return _PillUi(
          label: "Pending",
          icon: Icons.schedule,
          bg: const Color(0xFFFFF8E1),
          text: const Color(0xFF8D6E00),
          border: const Color(0xFFFFECB3),
          dot: const Color(0xFFFFC107),
        );
      case "paid":
        return _PillUi(
          label: "Paid",
          icon: Icons.credit_card,
          bg: const Color(0xFFE3F2FD),
          text: const Color(0xFF1565C0),
          border: const Color(0xFFBBDEFB),
          dot: const Color(0xFF2196F3),
        );
      case "shipped":
        return _PillUi(
          label: "Shipped",
          icon: Icons.local_shipping,
          bg: const Color(0xFFF3E5F5),
          text: const Color(0xFF6A1B9A),
          border: const Color(0xFFE1BEE7),
          dot: const Color(0xFF9C27B0),
        );
      case "delivered":
        return _PillUi(
          label: "Delivered",
          icon: Icons.check_circle,
          bg: const Color(0xFFE8F5E9),
          text: const Color(0xFF2E7D32),
          border: const Color(0xFFC8E6C9),
          dot: const Color(0xFF4CAF50),
        );
      case "cancelled":
      default:
        return _PillUi(
          label: "Cancelled",
          icon: Icons.cancel,
          bg: const Color(0xFFFFEBEE),
          text: const Color(0xFFC62828),
          border: const Color(0xFFFFCDD2),
          dot: const Color(0xFFE53935),
        );
    }
  }
}

class _PillUi {
  final String label;
  final IconData icon;
  final Color bg;
  final Color text;
  final Color border;
  final Color dot;

  const _PillUi({
    required this.label,
    required this.icon,
    required this.bg,
    required this.text,
    required this.border,
    required this.dot,
  });
}
