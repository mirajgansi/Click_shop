import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductRatingWidget extends ConsumerWidget {
  final String productId;
  final double avgRating;

  const ProductRatingWidget({
    super.key,
    required this.productId,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(productViewModelProvider);

    return Row(
      children: [
        Text(
          "Rating: ${avgRating.toStringAsFixed(1)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 10),

        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = avgRating >= starValue;

            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 22,
              onPressed: state.isProductActionLoading
                  ? null
                  : () async {
                      await ref
                          .read(productViewModelProvider.notifier)
                          .rateProduct(
                            productId: productId,
                            rating: starValue.toDouble(),
                          );

                      SnackbarUtils.showSuccess(
                        context,
                        "Rated $starValue star",
                      );
                    },
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? Colors.amber : cs.outline,
              ),
            );
          }),
        ),
      ],
    );
  }
}
