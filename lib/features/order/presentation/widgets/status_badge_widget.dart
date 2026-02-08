import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    Color bg;
    Color fg;

    switch (s) {
      case "delivered":
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green;
        break;
      case "shipped":
        bg = Colors.blue.withOpacity(0.12);
        fg = Colors.blue;
        break;
      case "cancelled":
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red;
        break;
      case "paid":
        bg = Colors.purple.withOpacity(0.12);
        fg = Colors.purple;
        break;
      case "pending":
      default:
        bg = Colors.orange.withOpacity(0.12);
        fg = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: fg),
      ),
    );
  }
}
