import 'package:click_shop/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DriverDashboardSkeleton extends StatelessWidget {
  final int activityCount;

  const DriverDashboardSkeleton({super.key, this.activityCount = 5});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark ? AppColors.darkSkeletonBase : AppColors.skeletonBase;
    final highlight = isDark
        ? AppColors.darkSkeletonHighlight
        : AppColors.skeletonHighlight;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header skeleton (greeting + date/time)
        _line(highlight: highlight, width: 220, height: 18),
        const SizedBox(height: 10),
        _line(highlight: highlight, width: 180, height: 12),

        const SizedBox(height: 20),

        // Stats grid skeleton (2 cards)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatCardSkeleton(base: base, highlight: highlight),
            _StatCardSkeleton(base: base, highlight: highlight),
          ],
        ),

        const SizedBox(height: 28),

        // Recent Activity title
        _line(highlight: highlight, width: 140, height: 16),
        const SizedBox(height: 12),

        // Activity list skeleton
        ...List.generate(
          activityCount,
          (_) => _ActivityTileSkeleton(base: base, highlight: highlight),
        ),
      ],
    );
  }

  Widget _line({
    required Color highlight,
    required double width,
    required double height,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: highlight,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  final Color base;
  final Color highlight;

  const _StatCardSkeleton({required this.base, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // icon circle
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Container(
                  height: 12,
                  width: 90,
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                // value
                Container(
                  height: 18,
                  width: 60,
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(10),
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

class _ActivityTileSkeleton extends StatelessWidget {
  final Color base;
  final Color highlight;

  const _ActivityTileSkeleton({required this.base, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
        ),
        title: Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: highlight,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            height: 11,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
