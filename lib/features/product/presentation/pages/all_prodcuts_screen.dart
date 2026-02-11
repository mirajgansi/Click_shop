import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllProdcutsScreen extends ConsumerWidget {
  const AllProdcutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productViewModelProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    final products = state.allProducts;

    if (products.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;

        if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return CardWidget(
              product: products[index], // ✅ real data
            );
          },
        );
      },
    );
  }
}
