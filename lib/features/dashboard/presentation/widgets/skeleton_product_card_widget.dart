import 'package:flutter/material.dart';
import 'package:click_shop/app/theme/app_colors.dart';

class ProductCardSkeleton extends StatefulWidget {
  const ProductCardSkeleton({super.key});

  @override
  State<ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.darkSkeletonBase
        : AppColors.skeletonBase;

    final highlightColor = isDark
        ? AppColors.darkSkeletonHighlight
        : AppColors.skeletonHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDark ? AppColors.darkSoftShadow : AppColors.softShadow,
          ),
          child: Stack(
            children: [
              // Shimmer Effect
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  alignment: Alignment(
                    -1.0 + (_controller.value * 2),
                    0,
                  ), // shimmer move
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [baseColor, highlightColor, baseColor],
                        stops: const [0.2, 0.5, 0.8],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
