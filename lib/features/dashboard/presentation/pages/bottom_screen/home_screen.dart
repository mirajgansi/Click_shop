import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
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

    // loading / error
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    // simple search filter (optional)
    final products = q.trim().isEmpty
        ? allProducts
        : allProducts
              .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
              .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // TOP: location + search + banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(
                    controller: _searchCtrl,
                    hint: "Search Store",
                    onChanged: (v) => setState(() => q = v),
                  ),

                  const SizedBox(height: 12),

                  _PromoBanner(
                    title: "Fresh Vegetables",
                    subtitle: "Get up to 40% off",
                    imageAsset:
                        "assets/images/banner_veg.png", // replace if you want
                    onTap: () {},
                  ),

                  const SizedBox(height: 14),

                  _SectionHeader(title: "Exclusive Offer", onSeeAll: () {}),
                ],
              ),
            ),
          ),

          // Exclusive Offer grid (use same products for now)
          if (products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text("No products found")),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => CardWidget(product: products[i]),
                  childCount: products.length >= 2 ? 2 : products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // matches your CardWidget
                ),
              ),
            ),

          // Best Selling header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: _SectionHeader(title: "Best Selling", onSeeAll: () {}),
            ),
          ),

          // Best Selling grid (again, same products for now)
          if (products.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final index = (i + 2) < products.length ? (i + 2) : i;
                  return CardWidget(product: products[index]);
                }, childCount: products.length >= 2 ? 2 : products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

/// ---------- widgets ----------

class _TopLocationRow extends StatelessWidget {
  final String location;
  final VoidCallback onNotify;

  const _TopLocationRow({required this.location, required this.onNotify});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        IconButton(
          onPressed: onNotify,
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

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
