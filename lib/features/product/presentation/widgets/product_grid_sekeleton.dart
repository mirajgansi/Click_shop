import 'package:click_shop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProductGridSkeleton extends StatelessWidget {
  final int count;
  final int crossAxisCount;
  final double childAspectRatio;

  const ProductGridSkeleton({
    super.key,
    this.count = 8,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark ? AppColors.darkSkeletonBase : AppColors.skeletonBase;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, i) {
        return _SkeletonCard(base: base);
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Color base;
  const _SkeletonCard({required this.base});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
