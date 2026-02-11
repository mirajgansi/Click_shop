import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final products = state.categoryProducts; // ✅ use this list

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? "Category")),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : products.isEmpty
          ? _EmptyCategoryWidget(title: widget.title)
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, i) {
                final product = products[i];
                return CardWidget(product: product);
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
