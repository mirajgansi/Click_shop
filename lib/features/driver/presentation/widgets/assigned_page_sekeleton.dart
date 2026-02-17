import 'package:click_shop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AssignedPageSkeleton extends StatelessWidget {
  final int count;

  const AssignedPageSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark ? AppColors.darkSkeletonBase : AppColors.skeletonBase;

    final highlight = isDark
        ? AppColors.darkSkeletonHighlight
        : AppColors.skeletonHighlight;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        return _DriverOrderSkeletonCard(base: base, highlight: highlight);
      },
    );
  }
}

class _DriverOrderSkeletonCard extends StatelessWidget {
  final Color base;
  final Color highlight;

  const _DriverOrderSkeletonCard({required this.base, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          _line(width: 120, height: 14),

          const SizedBox(height: 12),

          // Address line 1
          _line(width: double.infinity, height: 12),

          const SizedBox(height: 8),

          // Address line 2
          _line(width: MediaQuery.of(context).size.width * 0.6, height: 12),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              _line(width: 80, height: 14),

              // Status pill
              Container(
                height: 26,
                width: 70,
                decoration: BoxDecoration(
                  color: highlight,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line({required double width, required double height}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: highlight,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
