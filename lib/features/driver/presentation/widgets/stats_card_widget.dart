import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color baseColor;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final lightColor = baseColor.withOpacity(0.12);
    final darkBorder = baseColor.withOpacity(0.8);

    return Container(
      decoration: BoxDecoration(
        color: lightColor, // ✅ Light inside
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkBorder, // ✅ Dark border
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: baseColor.withOpacity(0.9), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: baseColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
