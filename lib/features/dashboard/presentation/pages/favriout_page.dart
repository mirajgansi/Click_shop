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
  Future<void> _load() async {
    await ref.read(productViewModelProvider.notifier).loadMyFavorites();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Favorites",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: SafeArea(top: false, child: _buildBody(context, state)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    final cs = Theme.of(context).colorScheme;
    final products = state.favoriteProducts;

    // Loading
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 44, color: cs.error),
              const SizedBox(height: 10),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.error, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text("Try again"),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 90),
            Icon(
              Icons.favorite_border_rounded,
              size: 70,
              color: cs.onSurface.withOpacity(0.7),
            ),
            const SizedBox(height: 14),
            Text(
              "No favorites yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the heart icon on any product to save it here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withOpacity(0.75)),
            ),
          ],
        ),
      );
    }

    // ✅ Responsive Grid like Home Page
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;

                int crossAxisCount;
                double aspectRatio;

                // ✅ Same breakpoint logic as your Home page
                if (width >= 1200) {
                  crossAxisCount = 6;
                  aspectRatio = 0.95;
                } else if (width >= 900) {
                  crossAxisCount = 5;
                  aspectRatio = 0.9;
                } else if (width >= 600) {
                  crossAxisCount = 4;
                  aspectRatio = 0.85;
                } else {
                  crossAxisCount = 2;
                  aspectRatio = 0.72;
                }

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final p = products[index];

                    // ✅ Same stagger effect as Home page
                    final yOffset = (index % 2 == 0) ? 0.0 : 22.0;

                    return Transform.translate(
                      offset: Offset(0, yOffset),
                      child: CardWidget(
                        key: ValueKey(p.id ?? index),
                        product: p,
                      ),
                    );
                  }, childCount: products.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 14,
                    childAspectRatio: aspectRatio,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
