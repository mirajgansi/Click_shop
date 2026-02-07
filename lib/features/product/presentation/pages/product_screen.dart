import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/widgets/my_favourite_button_widgets.dart';
import 'package:click_shop/core/widgets/my_review_button_widgets.dart';
import 'package:click_shop/features/cart/domain/usecases/add_cart_product_usecase.dart';
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
  int rating = 0;

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

  String _buildImageUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith("http")) return path;

    return "${ApiEndpoints.getHostUrl()}${path.startsWith("/") ? "" : "/"}$path";
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              _toast("Share coming soon");
            },
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final result = await ref
                  .read(addToCartUsecaseProvider)
                  .call(
                    AddToCartParams(
                      productId:
                          product.id ??
                          widget.productId, // use whichever you have
                      quantity: quantity,
                    ),
                  );

              result.fold(
                (failure) => _toast(failure.message),
                (_) => _toast("Added to basket "),
              );
            },
            child: const Text(
              "Add To Basket",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: product.image.isEmpty
                    ? Image.asset(
                        "assets/images/Group.jpg",
                        fit: BoxFit.contain,
                      )
                    : Image.network(ApiEndpoints.buildFileUrl(product.image)),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (keep your UI)
                  const Divider(),

                  sectionTitle("Product Detail"),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),

                  const Divider(),

                  listTile(title: "Nutritions", value: product.nutritionalInfo),

                  const Divider(),

                  listTile(
                    title: "Review",
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => MyReviewButtonWidgets(
                          isRated: index < rating,
                          onTap: () {
                            setState(() => rating = index + 1);
                            _toast("Rated ${index + 1} star(s)");
                          },
                        ),
                      ),
                    ),
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
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            )
          : null,
      trailing: trailingWidget,
    );
  }
}
