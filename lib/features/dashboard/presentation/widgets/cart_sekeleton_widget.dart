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

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                    box(h: 54, w: 54, radius: BorderRadius.circular(12)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: box(h: 14)),
                              const SizedBox(width: 10),
                              box(
                                h: 14,
                                w: 14,
                                radius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          box(h: 12, w: 90, radius: BorderRadius.circular(8)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              box(
                                h: 34,
                                w: 110,
                                radius: BorderRadius.circular(18),
                              ),
                              box(
                                h: 14,
                                w: 70,
                                radius: BorderRadius.circular(10),
                              ),
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
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: box(
              h: 56,
              w: double.infinity,
              radius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
