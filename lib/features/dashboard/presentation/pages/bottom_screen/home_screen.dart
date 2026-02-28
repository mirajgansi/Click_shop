import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/core/constants/app_categories.dart';
import 'package:click_shop/core/providers/socket_service_provider.dart';
import 'package:click_shop/core/services/connectivity/socket_service.dart';
import 'package:click_shop/features/auth/domain/usecases/save_fcm_token_usecase.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_card_widgets.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/skeleton_product_card_widget.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/presentation/pages/product_category_screen.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:click_shop/features/product/presentation/widgets/my_category_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum HomeFeedType { all, trending, popular, recent }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

Future<void> enableNotifications(BuildContext context, WidgetRef ref) async {
  final status = await Permission.notification.status;

  if (status.isGranted) {
    await _generateAndSendFcmToken(ref);
    return;
  }

  if (status.isDenied) {
    final res = await Permission.notification.request();
    if (res.isGranted) {
      await _generateAndSendFcmToken(ref);
    }
    return;
  }

  if (status.isPermanentlyDenied) {
    _showNotificationPermissionDialog(context);
    return;
  }
}

Future<void> _generateAndSendFcmToken(WidgetRef ref) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    await ref
        .read(saveFcmTokenUsecaseProvider)
        .call(SaveFcmTokenParams(token: token));
  } catch (e) {
    print("FCM: ERROR => $e");
  }
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
  bool _socketBooted = false;

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
    await _selectFeed(_feed);
  }

  late final SocketService _socket;

  @override
  void initState() {
    super.initState();
    _socket = ref.read(socketServiceProvider);
  }

  HomeFeedType _feed = HomeFeedType.all;

  Future<void> _selectFeed(HomeFeedType type) async {
    setState(() => _feed = type);

    if (q.trim().isNotEmpty) return;

    final vm = ref.read(productViewModelProvider.notifier);
    switch (type) {
      case HomeFeedType.all:
        await vm.loadProducts();
        break;
      case HomeFeedType.trending:
        await vm.loadTrending();
        break;
      case HomeFeedType.popular:
        await vm.loadPopular();
        break;
      case HomeFeedType.recent:
        await vm.loadRecent();
        break;
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final isSearching = q.trim().isNotEmpty;

    List<ProductEntity> listToShow;

    if (isSearching) {
      listToShow = state.allProducts;
    } else {
      switch (_feed) {
        case HomeFeedType.all:
          listToShow = state.allProducts;
          break;
        case HomeFeedType.trending:
          listToShow = state.trendingProducts;
          break;
        case HomeFeedType.popular:
          listToShow = state.popularProducts;
          break;
        case HomeFeedType.recent:
          listToShow = state.recentProducts;
          break;
      }
    }
    List<ProductEntity> filterLocal(List<ProductEntity> list) {
      if (!isSearching) return list;
      final s = q.trim().toLowerCase();
      return list.where((p) => p.name.toLowerCase().contains(s)).toList();
    }

    final bool isGridLoading = isSearching
        ? state.isLoading
        : (_feed == HomeFeedType.all
              ? state.isLoading
              : _feed == HomeFeedType.trending
              ? state.isTrendingLoading
              : _feed == HomeFeedType.popular
              ? state.isPopularLoading
              : state.isRecentLoading);
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
                    setState(() => _feed = HomeFeedType.all);
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
                            setState(() {
                              q = "";
                              _feed = HomeFeedType.all;
                            });
                            ref
                                .read(productViewModelProvider.notifier)
                                .initHome();
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text("All"),
                    selected: _feed == HomeFeedType.all,
                    onSelected: (_) => _selectFeed(HomeFeedType.all),
                  ),
                  ChoiceChip(
                    label: const Text("Trending"),
                    selected: _feed == HomeFeedType.trending,
                    onSelected: (_) => _selectFeed(HomeFeedType.trending),
                  ),
                  ChoiceChip(
                    label: const Text("Popular"),
                    selected: _feed == HomeFeedType.popular,
                    onSelected: (_) => _selectFeed(HomeFeedType.popular),
                  ),
                  ChoiceChip(
                    label: const Text("Recently Added"),
                    selected: _feed == HomeFeedType.recent,
                    onSelected: (_) => _selectFeed(HomeFeedType.recent),
                  ),
                ],
              ),
            ),
          ),
          // ---------------- PRODUCTS ----------------
          if (isGridLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;

                  int crossAxisCount;
                  double aspectRatio;

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
                    aspectRatio = 0.82;
                  }

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final yOffset = (index % 2 == 0) ? 0.0 : 22.0;

                      return Transform.translate(
                        offset: Offset(0, yOffset),
                        child: const ProductCardSkeleton(),
                      );
                    }, childCount: crossAxisCount * 6),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 14,
                      childAspectRatio: aspectRatio,
                    ),
                  );
                },
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
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;

                  int crossAxisCount;
                  double aspectRatio;

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
                    aspectRatio = 0.82;
                  }

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = products[index];
                      final yOffset = (index % 2 == 0) ? 0.0 : 22.0;

                      return Transform.translate(
                        offset: Offset(0, yOffset),
                        child: CardWidget(
                          key: ValueKey('${_feed.name}-${p.id}'),
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
