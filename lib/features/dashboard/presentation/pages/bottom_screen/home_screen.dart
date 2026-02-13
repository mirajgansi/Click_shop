import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/constants/app_categories.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/presentation/pages/product_category_screen.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/features/product/presentation/widgets/my_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String q = "";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final allProducts = state.allProducts;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    // Products shown on home
    final products = q.trim().isEmpty
        ? allProducts
        : allProducts
              .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
              .toList();

    // Categories row (also filtered by search)
    final filteredCats = q.trim().isEmpty
        ? appCategories
        : appCategories
              .where(
                (c) => c.title.toLowerCase().contains(q.trim().toLowerCase()),
              )
              .toList();

    final recentBase = state.recentProducts; // ✅ Recently Added
    final popularBase = state.popularProducts; // ✅ Popular
    final bestBase = state.trendingProducts; // ✅ Best Selling (using trending)

    // filter helper (search only affects displayed lists)
    List<ProductEntity> _filter(List<ProductEntity> list) {
      final s = q.trim().toLowerCase();
      if (s.isEmpty) return list;
      return list.where((p) => p.name.toLowerCase().contains(s)).toList();
    }

    final recentProducts = _filter(recentBase).take(10).toList();
    final popularProducts = _filter(popularBase).take(10).toList();
    final bestSellingProducts = _filter(bestBase).take(10).toList();

    // fallback: if API list empty, use allProducts (optional)
    final recent = recentProducts.isNotEmpty
        ? recentProducts
        : _filter(allProducts).take(10).toList();
    final popular = popularProducts.isNotEmpty
        ? popularProducts
        : _filter(allProducts).take(10).toList();
    final bestSelling = bestSellingProducts.isNotEmpty
        ? bestSellingProducts
        : _filter(allProducts).take(10).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // TOP: search + banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _PromoBanner(
                    title: "Fresh Vegetables",
                    subtitle: "Get up to 40% off",
                    imageAsset: "assets/images/banner_veg.png",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Exclusive Offer header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: _SectionHeader(title: "Exclusive Offer", onSeeAll: () {}),
            ),
          ),

          // Exclusive Offer row (10 items)
          SliverToBoxAdapter(
            child: products.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("No products found")),
                  )
                : _HorizontalProductRow(products: recent),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: _SectionHeader(title: "Groceries", onSeeAll: () {}),
            ),
          ),

          // Groceries row (rectangle categories)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 86,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: filteredCats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final cat = filteredCats[i];
                  return SizedBox(
                    width: 190,
                    child: CategoryCard(
                      title: cat.titleOneLine,
                      imagePath: cat.image,
                      backgroundColor: cat.bg,
                      borderColor: cat.border,
                      borderWidth: 1.2,
                      borderRadius: 16,
                      aspectRatio: 2.8, // ✅ rectangle
                      onTap: () {
                        AppRoutes.push(
                          context,
                          CategoryProductsPage(
                            categoryId: cat.id,
                            title: cat.titleOneLine,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // Best Selling header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: _SectionHeader(title: "Best Selling", onSeeAll: () {}),
            ),
          ),

          SliverToBoxAdapter(
            child: bestSelling.isEmpty
                ? const SizedBox.shrink()
                : _HorizontalProductRow(products: bestSelling),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: _SectionHeader(title: "Popular", onSeeAll: () {}),
            ),
          ),

          // Popular row
          SliverToBoxAdapter(
            child: popular.isEmpty
                ? const SizedBox.shrink()
                : _HorizontalProductRow(products: popular),
          ),
          // Groceries header
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
        ],
      ),
    );
  }
}

/// -------------------- Horizontal product row (scroll) --------------------

class _HorizontalProductRow extends StatelessWidget {
  final List<ProductEntity> products;

  const _HorizontalProductRow({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // tweak if needed
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return SizedBox(width: 170, child: CardWidget(product: products[i]));
        },
      ),
    );
  }
}

/// -------------------- widgets --------------------

class _PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final VoidCallback onTap;

  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFEFFAF2),
          border: Border.all(color: const Color(0xFFD9F3DF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  imageAsset,
                  width: 90,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const Spacer(),
        TextButton(onPressed: onSeeAll, child: const Text("See all")),
      ],
    );
  }
}
