import 'package:flutter/material.dart';

class StockPillBadge extends StatelessWidget {
  final int? stock;

  const StockPillBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool available = stock != null && stock! > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: available
            ? cs.primary.withOpacity(0.12)
            : cs.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: available ? cs.primary : cs.error,
              shape: BoxShape.circle,
            ),
            child: Icon(
              available ? Icons.check : Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            available ? "${stock!}+ in stock" : "Unavailable",
            style: TextStyle(
              color: available ? cs.primary : cs.error,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
