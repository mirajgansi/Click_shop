import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_stock_badge_widget.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(productViewModelProvider.notifier)
          .getProductById(widget.productId);
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _fmtDate(DateTime? date) {
    if (date == null) return "-";

    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  bool isDescriptionExpanded = false;
  bool isNutritionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final state = ref.watch(productViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(state.error!)),
      );
    }

    final product = state.selectedProduct;
    if (product == null) {
      return const Scaffold(body: Center(child: Text("Product not found")));
    }

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: cs.onSurface),
            onPressed: () => _toast("Share coming soon"),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final result = await ref
                  .read(addToCartUsecaseProvider)
                  .call(
                    AddToCartParams(
                      productId: product.id ?? widget.productId,
                      quantity: quantity,
                    ),
                  );

              result.fold(
                (failure) => _toast(failure.message),
                (_) => _toast("Added to basket"),
              );
            },
            child: const Text(
              "Add To Basket",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surfaceVariant,
              ),
              child: Center(
                child: (product.image.isEmpty)
                    ? Image.asset(
                        "assets/images/Group.jpg",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        ApiEndpoints.buildFileUrl(product.image),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StockPillBadge(stock: product.inStock),
                    ],
                  ),
                  Text(
                    "Rs. ${product.price}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Divider(color: cs.outlineVariant.withOpacity(0.6)),

                  sectionTitle("Product Info"),
                  const SizedBox(height: 8),

                  infoTile(context, "Category", product.category),
                  infoTile(
                    context,
                    "Manufacturer",
                    product.manufacturer ?? "-",
                  ),
                  infoTile(
                    context,
                    "Manufacture Date",
                    _fmtDate(product.manufactureDate),
                  ),
                  infoTile(
                    context,
                    "Expire Date",
                    _fmtDate(product.expireDate),
                  ),

                  const Divider(),

                  sectionTitle("Description"),
                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.description,
                        maxLines: isDescriptionExpanded ? null : 2,
                        overflow: isDescriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isDescriptionExpanded = !isDescriptionExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            isDescriptionExpanded ? "Show Less" : "Read More",
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  sectionTitle("Nutritions"),
                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nutritionalInfo,
                        maxLines: isNutritionExpanded ? null : 2,
                        overflow: isNutritionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isNutritionExpanded = !isNutritionExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            isNutritionExpanded ? "Show Less" : "Read More",
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
    );
  }

  Widget infoTile(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget listTile({
    required String title,
    String? value,
    Widget? trailingWidget,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: value != null
          ? Text(
              value,
              maxLines: 2, // 🔥 THIS TRUNCATES
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            )
          : null,
      trailing: trailingWidget,
    );
  }
}
