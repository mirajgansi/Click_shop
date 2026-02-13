import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/constants/app_categories.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/presentation/pages/product_category_screen.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/features/product/presentation/widgets/my_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _controller = TextEditingController();
  String q = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final productState = ref.watch(productViewModelProvider);
    final searchedProducts = productState.allProducts;
    final filtered = appCategories.where((c) {
      return c.title.toLowerCase().contains(q.trim().toLowerCase());
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() => q = v);

                if (v.trim().isNotEmpty) {
                  ref.read(productViewModelProvider.notifier).search(v);
                }
              },
              decoration: InputDecoration(
                hintText: "Search Store",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: q.trim().isEmpty
                  ? _buildCategoryGrid(context, filtered)
                  : _buildProductGrid(context, searchedProducts),
            ),
          ],
        ),
      ),
    );
  }
}

int _gridCrossAxisCount(BuildContext context) {
  final w = MediaQuery.of(context).size.width;

  if (w >= 1200) return 5;
  if (w >= 900) return 4;
  if (w >= 600) return 3;
  return 2;
}

double _categoryRatio(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return w >= 600 ? 1 : 1.0;
}

double _productRatio(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 900) return 1.0;
  if (w >= 600) return 0.95;
  return 0.85;
}

Widget _buildCategoryGrid(BuildContext context, List filtered) {
  final cols = _gridCrossAxisCount(context);

  return GridView.builder(
    itemCount: filtered.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: _categoryRatio(context),
    ),
    itemBuilder: (context, i) {
      final cat = filtered[i];

      return CategoryCard(
        title: cat.title,
        imagePath: cat.image,
        backgroundColor: cat.bg,
        borderColor: cat.border,
        borderWidth: 1.2,
        borderRadius: 18,
        aspectRatio: 1,
        onTap: () {
          AppRoutes.push(
            context,
            CategoryProductsPage(categoryId: cat.id, title: cat.titleOneLine),
          );
        },
      );
    },
  );
}

Widget _buildProductGrid(BuildContext context, List products) {
  if (products.isEmpty) {
    return const Center(child: Text("No products found"));
  }

  final w = MediaQuery.of(context).size.width;

  return GridView.builder(
    itemCount: products.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: w >= 600 ? 2 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: w >= 600 ? 1.0 : 0.85,
    ),
    itemBuilder: (context, i) {
      return CardWidget(product: products[i]);
    },
  );
}
