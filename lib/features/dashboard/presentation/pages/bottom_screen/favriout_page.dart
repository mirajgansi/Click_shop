import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteProductsScreen extends ConsumerStatefulWidget {
  const FavoriteProductsScreen({super.key});

  @override
  ConsumerState<FavoriteProductsScreen> createState() =>
      _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState
    extends ConsumerState<FavoriteProductsScreen> {
  @override
  void initState() {
    super.initState();

    // load favorites once when screen opens
    Future.microtask(() async {
      await ref.read(productViewModelProvider.notifier).loadMyFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    final products = state.favoriteProducts;

    if (products.isEmpty) {
      return const Center(child: Text("No favorite products yet"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;

        if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(productViewModelProvider.notifier).loadMyFavorites();
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return CardWidget(product: products[index]);
            },
          ),
        );
      },
    );
  }
}
