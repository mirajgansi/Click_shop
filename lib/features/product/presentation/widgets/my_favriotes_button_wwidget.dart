import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';

class ProductFavoriteButton extends ConsumerWidget {
  final String productId;
  final List<String> favorites;

  const ProductFavoriteButton({
    super.key,
    required this.productId,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(productViewModelProvider);
    final authState = ref.watch(AuthViewModelProvider);

    final userId = authState.user?.userId;
    final isFav = userId != null && favorites.contains(userId);

    return IconButton(
      onPressed: state.isProductActionLoading
          ? null
          : () async {
              if (userId == null) {
                SnackbarUtils.showError(context, "Please login first");
                return;
              }

              await ref
                  .read(productViewModelProvider.notifier)
                  .toggleFavorite(productId: productId);

              SnackbarUtils.showSuccess(
                context,
                isFav ? "Removed from favorites" : "Added to favorites",
              );
            },
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : cs.primary,
      ),
    );
  }
}
