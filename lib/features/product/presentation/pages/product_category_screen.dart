import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/features/product/presentation/widgets/product_grid_sekeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryProductsPage extends ConsumerStatefulWidget {
  final String categoryId;
  final String? title;

  const CategoryProductsPage({super.key, required this.categoryId, this.title});

  @override
  ConsumerState<CategoryProductsPage> createState() =>
      _CategoryProductsPageState();
}

class _CategoryProductsPageState extends ConsumerState<CategoryProductsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(productViewModelProvider.notifier)
          .loadProductsByCategory(widget.categoryId);
    });
  }

  /// Responsive grid config (same idea as HomeScreen)
  (int, double) _gridSpec(double width) {
    if (width >= 1200) return (6, 0.95);
    if (width >= 900) return (5, 0.90);
    if (width >= 600) return (4, 0.85);
    return (2, 0.72);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final products = state.categoryProducts;

    final width = MediaQuery.of(context).size.width;
    final (crossAxisCount, aspectRatio) = _gridSpec(width);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? "Category")),
      body: state.isLoading
          ? ProductGridSkeleton(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
            )
          : state.error != null
          ? Center(child: Text(state.error!))
          : products.isEmpty
          ? _EmptyCategoryWidget(title: widget.title)
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 12,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, i) {
                return CardWidget(product: products[i]);
              },
            ),
    );
  }
}

class _EmptyCategoryWidget extends StatelessWidget {
  final String? title;

  const _EmptyCategoryWidget({this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_shopping_cart,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No ${title ?? "Products"} Available",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Please check back later.",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
