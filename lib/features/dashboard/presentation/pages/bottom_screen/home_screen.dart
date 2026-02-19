import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/constants/app_categories.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/skeleton_product_card_widget.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/presentation/pages/product_category_screen.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/features/product/presentation/widgets/my_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

Future<bool> requestNotificationPermission(BuildContext context) async {
  final status = await Permission.notification.status;

  if (status.isGranted) return true;

  if (status.isDenied) {
    final res = await Permission.notification.request();
    return res.isGranted;
  }

  if (status.isPermanentlyDenied) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enable Notifications"),
        content: const Text(
          "Notifications are permanently denied. Enable them from App Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
    return false;
  }

  return false;
}

void _showNotificationPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Enable Notifications"),
      content: const Text(
        "Notifications are permanently denied. Please enable them from App Settings.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
          child: const Text("Open Settings"),
        ),
      ],
    ),
  );
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String q = "";
  bool _booted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_booted) {
      _booted = true;
      Future.microtask(() {
        ref.read(productViewModelProvider.notifier).initHome();
      });
    }
  }

  Future<void> onRefresh() async {
    final vm = ref.read(productViewModelProvider.notifier);

    await vm.initHome(); // all products / home data
    await vm.loadTrending(); // best seller
    await vm.loadPopular(); // favorites/most bought
    // await vm.loadRecent();  // if you still use recent
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await requestNotificationPermission(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final isSearching = q.trim().isNotEmpty;

    List<ProductEntity> listToShow = state.allProducts;

    List<ProductEntity> filterLocal(List<ProductEntity> list) {
      if (!isSearching) return list;
      final s = q.trim().toLowerCase();
      return list.where((p) => p.name.toLowerCase().contains(s)).toList();
    }

    final products = filterLocal(listToShow).take(20).toList();
    final filteredCats = appCategories;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  setState(() => q = v);

                  final query = v.trim();
                  if (query.isNotEmpty) {
                    ref.read(productViewModelProvider.notifier).search(query);
                  } else {
                    ref.read(productViewModelProvider.notifier).initHome();
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearching
                      ? IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => q = "");
                            ref
                                .read(productViewModelProvider.notifier)
                                .initHome();
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          if (!isSearching) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: const _SectionHeader(title: "Groceries"),
              ),
            ),
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
                        aspectRatio: 2.8,
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
          ],

          // ---------------- TITLE ----------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: _SectionHeader(
                title: isSearching ? "Search Results" : "All Products",
              ),
            ),
          ),

          // ---------------- PRODUCTS ----------------
          if (state.isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final yOffset = (index % 2 == 0) ? 0.0 : 22.0;

                  return Transform.translate(
                    offset: Offset(0, yOffset),
                    child: const ProductCardSkeleton(),
                  );
                }, childCount: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
              ),
            )
          else if (products.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: Center(
                  child: Text(
                    isSearching ? "No results for \"$q\"" : "No products",
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = products[index];
                  final yOffset = (index % 2 == 0) ? 0.0 : 22.0;

                  return Transform.translate(
                    offset: Offset(0, yOffset),
                    child: CardWidget(key: ValueKey(p.id ?? index), product: p),
                  );
                }, childCount: products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
