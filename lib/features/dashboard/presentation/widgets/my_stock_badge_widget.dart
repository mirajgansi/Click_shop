import 'package:flutter/material.dart';

class StockPillBadge extends StatelessWidget {
  final int? stock;

  const StockPillBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final bool available = stock != null && stock! > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: available ? const Color(0xFFE9F8EC) : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: available ? const Color(0xFF22C55E) : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              available ? Icons.percent : Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            available ? "${(stock!)}+ in stock " : "Unavailable",
            style: TextStyle(
              color: available ? const Color(0xFF16A34A) : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
