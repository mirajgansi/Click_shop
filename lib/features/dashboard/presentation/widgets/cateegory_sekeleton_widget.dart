import 'package:click_shop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark ? AppColors.darkSkeletonBase : AppColors.skeletonBase;

    return Container(
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
