import "package:click_shop/app/theme/app_colors.dart";
import "package:flutter/material.dart";

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

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

    Widget line({double w = double.infinity, double h = 12}) =>
        box(h: h, w: w, radius: BorderRadius.circular(10));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: cs.onSurface),
            onPressed: null,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE PLACEHOLDER
            Container(
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: base,
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + STOCK BADGE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: line(h: 18)),
                      const SizedBox(width: 10),
                      box(h: 26, w: 70, radius: BorderRadius.circular(999)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // PRICE
                  line(w: 120, h: 14),

                  const SizedBox(height: 12),
                  Divider(color: cs.outlineVariant.withOpacity(0.6)),

                  // PRODUCT INFO
                  line(w: 140, h: 14),
                  const SizedBox(height: 12),

                  _InfoRowSkeleton(base: base),
                  _InfoRowSkeleton(base: base),
                  _InfoRowSkeleton(base: base),
                  _InfoRowSkeleton(base: base),

                  const Divider(),

                  // DESCRIPTION
                  line(w: 130, h: 14),
                  const SizedBox(height: 12),
                  line(),
                  const SizedBox(height: 8),
                  line(w: MediaQuery.of(context).size.width * 0.7),

                  const Divider(),

                  // NUTRITIONS
                  line(w: 130, h: 14),
                  const SizedBox(height: 12),
                  line(),
                  const SizedBox(height: 8),
                  line(w: MediaQuery.of(context).size.width * 0.65),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  final Color base;
  const _InfoRowSkeleton({required this.base});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 130,
            height: 12,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
