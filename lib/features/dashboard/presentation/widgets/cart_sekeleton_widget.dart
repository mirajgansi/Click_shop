import 'package:click_shop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CartSkeleton extends StatelessWidget {
  final int itemCount;
  const CartSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSkeletonBase : AppColors.skeletonBase;

    Widget box({double? h, double? w, BorderRadius? radius}) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: base,
          borderRadius: radius ?? BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image skeleton
                box(h: 54, w: 54, radius: BorderRadius.circular(12)),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + close icon placeholder
                      Row(
                        children: [
                          Expanded(child: box(h: 14)),
                          const SizedBox(width: 10),
                          box(h: 14, w: 14, radius: BorderRadius.circular(4)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // stock line
                      box(h: 12, w: 90, radius: BorderRadius.circular(8)),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // qty pill skeleton
                          box(h: 34, w: 110, radius: BorderRadius.circular(18)),
                          // price skeleton
                          box(h: 14, w: 70, radius: BorderRadius.circular(10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // bottom checkout skeleton (looks like your real one)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: box(
            h: 56,
            w: double.infinity,
            radius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
